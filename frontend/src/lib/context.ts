import { createContext, useContext } from 'react';
import { Product, ShoppingCartLine } from './types';

type ShoppingCartContextWithUpdate = {
    items: ShoppingCartLine[];
    addToCart: (product: Product, quantity?: number) => void;
    removeFromCart: (product: Product) => void;
    updateCartLine: (product: Product, quantite: number) => void;
};

export const ShoppingCartContext = createContext<ShoppingCartContextWithUpdate>(
    {
        items: [],
        addToCart: () => {},
        removeFromCart: () => {},
        updateCartLine: () => {},
    }
);


export const useCartContext = () => {
    return useContext(ShoppingCartContext);
}