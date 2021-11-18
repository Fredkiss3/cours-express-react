import router from 'express-promise-router';
import {
    authentifierClient,
    creerClient,
    recupererClient,
} from '../controllers/users';
import { authentificationClientMiddleware } from '../middleware/auth';

const Router = router();

Router.post('/create', creerClient);
// Router.get(/^\/(\d+)$/, recupererClient);

Router.get('/authenticate', authentifierClient);
Router.get('/me', authentificationClientMiddleware, recupererClient);

export { Router as userRoutes };
