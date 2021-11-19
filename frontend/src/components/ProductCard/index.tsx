import { Button } from '../Button';
import { Link } from '../Link';
import { floatToEUR } from '../../lib/functions';

interface ProductCardProps {
  nom: string;
  image: string;
  prix: number;
  url: string;
  stock: number;
  onAddToCartClicked: () => void;
}

export function ProductCard(props: ProductCardProps) {
  const {nom, url, prix, image, stock, onAddToCartClicked} = props;

  return <div className={'col-4 mb-4'}>
    <div className="card">
      <img
        src={image}
        className="card-img-top"
        alt="Image test"
      />
      <div className="card-body">
        <h4>{nom}</h4>
        <h5 className="card-title text-success fw-bold">{floatToEUR(prix)}</h5>
        <Button text={'Ajouter Au panier'} onClick={onAddToCartClicked} disabled={stock === 0}  />
        <br/>
        <Link href={url} text={'Détails'} className={'card-link'} />
      </div>
    </div>
  </div>;
}