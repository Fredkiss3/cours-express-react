import jwt from 'jsonwebtoken';
import { NextFunction, Request, Response } from 'express';

export const authentificationClientMiddleware = (
    req: Request,
    res: Response,
    next: NextFunction
) => {
    if(!req.headers.authorization) {
        return res.status(403).json({ message: 'Accès Interdit' });
    }

    const [bearer, token] = req.headers.authorization!.split(' '); // Séparation du token en deux parties : Bearer et le token

    if (token === undefined || bearer !== 'Bearer') {
        return res
            .status(403)
            .send({ message: 'Accès interdit.' });
    } else {
        // @ts-ignore
        const decodedToken = jwt.verify(token, process.env.JWT_SECRET);

        // Si l'utilisateur est un client, il a accès à la ressource
        if (decodedToken.isClient) {
            res.locals.user = {
                id: decodedToken.id,
                isClient: decodedToken.isClient,
            };

            return next();
        } else {
            return res
                .status(401)
                .send({ message: 'Accès non autorisé à la ressource.' });
        }
    }
};
