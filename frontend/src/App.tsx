import './App.css';
import { Product, ShoppingCartLine } from './lib/types';
import { useEffect, useState } from 'react';
import { HomePage } from './pages/HomePage';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { ShoppingCartPage } from './pages/ShoppingCartPage';
import { ShoppingCartContext } from './lib/context';

function App() {
    const [shoppingCartItems, setShoppingCartItems] = useState<
        ShoppingCartLine[]
    >([]);

    // au démarrage du composant
    useEffect(() => {
        const shoppingCart = localStorage.getItem('cart');
        if (shoppingCart) {
            setShoppingCartItems(JSON.parse(shoppingCart));
        }
    }, []);

    // au changement de shoppingCart
    useEffect(() => {
        if (shoppingCartItems) {
            localStorage.setItem('cart', JSON.stringify(shoppingCartItems));
        }
    }, [shoppingCartItems]);

    // Fonction pour ajouter un produit au panier
    function addToCart(product: Product, quantity: number = 1) {
        // mettre à jour le panier dans le state
        setShoppingCartItems((shoppingCartItems) => {
            // copier le panier
            const newItems = [...shoppingCartItems];

            // vérifier que le produit n'est pas déjà dans le panier
            const index = newItems.findIndex(
                (item) => item.product.id === product.id
            );

            // si le produit est déjà dans le panier mettre à jour la quantité
            if (index !== -1) {
                const stock = newItems[index].product.stock;
                const updatedQuantity = newItems[index].quantity + quantity;

                if (updatedQuantity <= stock) {
                    newItems[index].quantity = updatedQuantity;
                } else {
                    alert(
                        `Vous ne pouvez pas ajouter plus de ${stock} ${newItems[index].product.nom} dans le panier `
                    );
                }
            } else {
                // sinon ajouter le produit au panier
                newItems.push({ product, quantity: quantity });
            }

            return newItems;
        });
    }

    function updateCartLine(product: Product, quantity: number) {
        // mettre à jour le panier dans le state
        setShoppingCartItems((shoppingCartItems) => {
            // copier le panier
            const newItems = [...shoppingCartItems];

            // vérifier que le produit n'est pas déjà dans le panier
            const index = newItems.findIndex(
                (item) => item.product.id === product.id
            );

            // si le produit est déjà dans le panier mettre à jour la quantité
            if (index !== -1) {
                newItems[index].quantity = quantity;
            }

            return newItems;
        });
    }


    function removeFromCart(product: Product) {
        // mettre à jour le panier dans le state
        setShoppingCartItems((shoppingCartItems) => {
            // copier le panier
            let newItems = [...shoppingCartItems];
            return newItems.filter((item) => item.product.id !== product.id);
        });
    }

    return (
        <ShoppingCartContext.Provider
            value={{
                items: shoppingCartItems,
                addToCart: addToCart,
                updateCartLine: updateCartLine,
                removeFromCart: removeFromCart,
            }}
        >
            <div className={'container'}>
                <BrowserRouter>
                    <Routes>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/panier" element={<ShoppingCartPage />} />
                    </Routes>
                </BrowserRouter>
            </div>
        </ShoppingCartContext.Provider>
    );
}

export default App;
