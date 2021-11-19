import './index.css'
import { useState } from 'react';
import { Product } from '../../lib/types';
import axios from 'axios';

export function SearchBar() {
    const [search, setSearch] = useState('');
    const [results, setResults] = useState<Product[]>([]);

    function handleInputChange(value: string) {
       setSearch(value);

       // ajax vers le serveur pour récupérer les résultats
        const params = new URLSearchParams();
        params.append('search', value); // search=Bouteille+cris

        axios.get(`http://localhost:3030/api/products/search?${params.toString()}`).then(res => {
            setResults(res.data.success);
            console.log(res.data.success);
        });
    }

    return (
        <form className="d-flex gap-2">
            <div className='dropdown'>
                <input
                    className="form-control me-2"
                    autoComplete={"off"}
                    type="search"
                    name={"q"}
                    placeholder="Search"
                    value={search}
                    onChange={(e) => { handleInputChange(e.target.value) }}
                />
                <ul className={`dropdown-menu search-dropdown ${search.trim().length > 0 && results.length > 0  && 'show'}`} aria-labelledby="dropdownMenuButton1">
                    {results.map(product => (
                        <li key={product.id} className="dropdown-item">
                            <a href={`/products/${product.id}`}>{product.nom}</a>
                        </li>
                    ))}
                </ul>
            </div>
            <button className="btn btn-success" type="submit">
                Rechercher
            </button>


        </form>
    );
}
