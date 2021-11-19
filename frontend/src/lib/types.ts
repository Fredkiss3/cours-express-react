
export type Product = {
    id: number;
    nom: string;
    prix: number;
    stock: number;
    description?: string;
    image: string;
}


export type ShoppingCartLine = {
    product: Product;
    quantity: number;
}