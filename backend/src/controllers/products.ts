import { pool } from '../config/database';
import { Request, Response } from 'express';

export const recupererProduits = async (req: Request, res: Response, next: any) => {
    let connexion;
    try {
        connexion = await pool.getConnection();
        const result = await connexion.query(`CALL GetAllProduits()`);
        const produits = result[0];

        return res.status(200).json({ success: produits });
    } catch (error) {
        // @ts-ignore
        return res.status(400).json({ error: error.message });
    } finally {
        if (connexion) connexion.end();
    }
};

export const rechercherProduits = async (req: Request, res: Response, next: any) => {
    let connexion;
    try {
        connexion = await pool.getConnection();

        const query = req.query.search;

        const result = await connexion.query(`CALL RechercherProduit(?)`, [
            query ?? ''
        ]);

        const produits = result[0];
        return res.status(200).json({ success: produits });
    } catch (error) {
        // @ts-ignore
        return res.status(400).json({ error: error.message });
    } finally {
        if (connexion) connexion.end();
    }
};

export const recupererFicheProduit = async (req: Request, res: Response, next: any) => {
    let connexion;
    try {
        connexion = await pool.getConnection();
        const id = req.params[0];
        const result = await connexion.query(`CALL GetFicheProduit(?)`, [
           id
        ]);
        const produits = result[0];

        return res.status(200).json({ success: produits });
    } catch (error) {
        // @ts-ignore
        return res.status(400).json({ error: error.message });
    } finally {
        if (connexion) connexion.end();
    }
};
