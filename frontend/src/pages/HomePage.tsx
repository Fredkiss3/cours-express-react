import { Header } from '../components/Header';
import { ProductCard } from '../components/ProductCard';
import { Product } from '../lib/types';
import { useCartContext } from '../lib/context';
import { useEffect, useState } from 'react';
import axios from 'axios';


export function HomePage() {
    const [products, setProducts] = useState<Product[]>([]);

    // Au démarrage, on récupère les produits depuis le serveur express
    useEffect(() => {
        axios.get('http://localhost:3030/api/products').then((res) => {
            setProducts(res.data.success);
        });
    },  []);


    const { addToCart } = useCartContext();

    return (
        <>
            <Header />

            <main className={'row mt-5'}>
                {products.map((product) => (
                    <ProductCard
                        key={product.id}
                        onAddToCartClicked={() => {
                            addToCart(product);
                        }}
                        stock={product.stock}
                        nom={product.nom}
                        prix={product.prix}
                        url={'#'}
                        image={product.image}
                    />
                ))}
            </main>
        </>
    );
}
