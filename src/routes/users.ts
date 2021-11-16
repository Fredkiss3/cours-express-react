import router from 'express-promise-router';
import { authentifierClient, creerClient, recupererClient } from "../controllers/users";


const Router = router();

Router.post('/create', creerClient);
Router.get(/^\/(\d+)$/, recupererClient);
Router.get('/authenticate', authentifierClient);


export {
    Router as userRoutes
};