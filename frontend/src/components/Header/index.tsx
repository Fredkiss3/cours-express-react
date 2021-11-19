import { SearchBar } from '../SearchBar';
import { ShoppingCart } from '../ShoppingCart';
import { ClientButton } from '../ClientButton';
import { Link } from 'react-router-dom';


export function Header() {

    return (
        <>
            <header>
                <nav className="navbar navbar-expand-sm navbar-dark fixed-top bg-dark">
                    <div className="container-fluid">
                        <Link className="navbar-brand" to="/">
                            Logo
                        </Link>
                        <button
                            className="navbar-toggler"
                            type="button"
                            data-bs-toggle="collapse"
                            data-bs-target="#navbarCollapse"
                            aria-controls="navbarCollapse"
                            aria-expanded="false"
                            aria-label="Toggle navigation"
                        >
                            <span className="navbar-toggler-icon" />
                        </button>
                        <SearchBar />
                        <div className={'d-flex gap-2'}>
                            <ShoppingCart />
                            <ClientButton connected={false} />
                        </div>
                    </div>
                </nav>
            </header>
        </>
    );
}
