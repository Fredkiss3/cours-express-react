import { ShoppingCartLine } from '../../lib/types';
import { SelectQuantity } from '../SelectQuantity';
import { useCartContext } from '../../lib/context';
import { floatToEUR } from '../../lib/functions';
import { IconButton } from '../IconButton';

interface ShoppingCartItemProps {
    item: ShoppingCartLine;
}

export function ShoppingCartItem(props: ShoppingCartItemProps) {
    const { item } = props;
    const { updateCartLine, removeFromCart } = useCartContext();

    function handleChange(quantity: number) {
        updateCartLine(item.product, quantity);
    }

    return (
        <div>
            <div className="card mb-3">
                <div className="row g-0">
                    <div className="col-md-3">
                        <img
                            src={item.product.image}
                            className="img-fluid rounded-start"
                            alt="..."
                        />
                    </div>

                    <div className="col-md-9">
                        <div className="card-body">
                            <h5 className="card-title">{item.product.nom}</h5>
                            <h6 className="card-text fs-4 text-danger">
                                {floatToEUR(item.product.prix * item.quantity)}
                            </h6>
                            <div>
                                <SelectQuantity
                                    quantity={item.quantity}
                                    onChange={handleChange}
                                    maxQuantity={item.product.stock}
                                />
                                <br />
                                <IconButton
                                    text={'Supprimer'}
                                    onClick={() => {
                                        removeFromCart(item.product);
                                    }}
                                    icon={'trash'}
                                    color={'danger'}
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
