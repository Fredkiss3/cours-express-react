import { Link } from 'react-router-dom';
import { useCartContext } from '../../lib/context';

export function ShoppingCart() {
    const { items } = useCartContext();

    let quantity = 0;
    items.forEach((item) => {
        quantity += item.quantity;
    });

    return (
        <Link
            type="button"
            className="btn btn-primary position-relative"
            to={'/panier'}
        >
            {quantity > 0 ? (
                <i className="bi bi-cart-fill" />
            ) : (
                <i className="bi bi-cart" />
            )}
            <span className="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                {quantity}
            </span>
        </Link>
    );
}
