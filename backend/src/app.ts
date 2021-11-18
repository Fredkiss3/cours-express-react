// Configurer l'environnement de l'application
import dotenv from "dotenv";
dotenv.config({path: `${__dirname}/config/${process.env.NODE_ENV}.env`})


import express from 'express'
import cors from 'cors';
import {userRoutes} from "./routes/users";

// Créer une instance de l'application
const app = express()

// CORS et JSON
app.use(cors());
app.use(express.json());


// Routes
app.use('/api/users', userRoutes);

app.get('/api', (_, res) => res.send("Hello from API v1"));

app.listen(process.env.PORT, () => console.log(`Back end is running on PORT ${process.env.PORT}`));
