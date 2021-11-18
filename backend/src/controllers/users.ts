import { pool } from '../config/database';
import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export const creerClient = async (req: Request, res: Response, next: any) => {
    let connexion;
    try {
        connexion = await pool.getConnection();

        // On hashe le mot de passe
        const mdpHashe = await bcrypt.hash(req.body.mdp, 12);

        // les "?" sont des marqueurs pour indiquer que la requête est préparée
        const result = await connexion.query(`CALL CreerClient(?, ?, ?, ?)`, [
            // correspond à => { nom: "...", prenom: "...", email:  "...", mdp: "..." }
            req.body.nom,
            req.body.prenom,
            req.body.email,
            mdpHashe,
        ]);
        return res.status(200).json({ success: result });
    } catch (error) {
        // @ts-ignore
        return res.status(400).json({ error: error.message });
    } finally {
        if (connexion) connexion.end();
    }
};

export const recupererClient = async (
    req: Request,
    res: Response,
    next: any
) => {
    let connexion;
    try {
        connexion = await pool.getConnection();

        const id = res.locals.user.id; // correspond à => :id

        const result = await connexion.query(`CALL GetClientParId(?)`, [id]);

        const client = result[0][0];

        return res.status(200).json({
            success: {
                id: client.id,
                email: client.email,
                nom: client.nom,
                prenom: client.prenom,
            },
        });
    } catch (error) {
        // @ts-ignore
        return res.status(400).json({ error: error.message });
    } finally {
        if (connexion) connexion.end();
    }
};

export const authentifierClient = async (
    req: Request,
    res: Response,
    next: any
) => {
    let connexion;
    try {
        connexion = await pool.getConnection();

        const email = req.body.email;

        const result = await connexion.query(`CALL GetClientParEmail(?)`, [
            email,
        ]);

        // Vérifier l'adresse email
        if (result[0].length > 0) {
            const client = result[0][0];

            // Vérifier le mot de passe
            const match = await bcrypt.compare(req.body.mdp, client.mdp);
            if (match) {
                // Créer le token pour permettre d'authentifier le client
                const token = jwt.sign(
                    {
                        id: client.id,
                        isClient: true,
                    },
                    // @ts-ignore
                    process.env.JWT_SECRET,
                    {
                        expiresIn: '1d',
                        algorithm: 'HS256',
                    }
                );

                return res.status(200).json({
                    success: 'Connexion effectuée avec succès',
                    token: token,
                });
            } else {
                return res
                    .status(400)
                    .json({ error: 'Mot de passe incorrect' });
            }
        } else {
            return res
                .status(400)
                .json({ error: "Cet email n'appartient à aucun client" });
        }
    } catch (error) {
        // @ts-ignore
        return res.status(400).json({ error: error.message });
    } finally {
        if (connexion) connexion.end();
    }
};
