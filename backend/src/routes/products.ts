import router from 'express-promise-router';
import {
    recupererProduits,
    recupererFicheProduit,
    rechercherProduits,
} from '../controllers/products';

const Router = router();

Router.get('/', recupererProduits); // /api/products/ => renvoyer tous les produits
Router.get(/^\/(\d+)$/, recupererFicheProduit);
Router.get('/search', rechercherProduits);

export { Router as productsRoutes };
