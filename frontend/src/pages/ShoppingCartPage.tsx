import { Header } from '../components/Header';
import { useCartContext } from '../lib/context';
import { ShoppingCartItem } from '../components/ShoppingCartItem';
import { ShoppingCartLine } from '../lib/types';
import { floatToEUR } from '../lib/functions';
import { SubTitle } from '../components/SubTitle';

export function ShoppingCartPage() {
    const { items } = useCartContext();

    let total = 0;
    items.forEach((item) => {
        total += item.product.prix * item.quantity;
    });

    return (
        <>
            <Header />
            <main className={'mt-5'}>
                <ProductListSection items={items} />
                {total > 0 && <TotalSection total={total} />}
            </main>
        </>
    );
}

interface ProductListSectionProps {
    items: ShoppingCartLine[];
}

function ProductListSection(props: ProductListSectionProps) {
    const { items } = props;
    return (
        <>
            <h2>Liste des produits</h2>
            {items.length > 0 ? (
                <ul className={'list-group'}>
                    {items.map((item) => (
                        <ShoppingCartItem key={item.product.id} item={item} />
                    ))}
                </ul>
            ) : (
                <SubTitle
                    content={'Votre panier est vide'}
                    className={'text-secondary'}
                />
            )}
        </>
    );
}

interface TotalSectionProps {
    total: number;
}

function TotalSection(props: TotalSectionProps) {
    const { total } = props;
    return (
        <>
            <h2>Total: {floatToEUR(total)}</h2>
        </>
    );
}
