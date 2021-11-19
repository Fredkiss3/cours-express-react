import './index.css'
import { useState } from "react";

interface ClientButtonProps {
  connected: boolean;
}

export function ClientButton(props: ClientButtonProps) {

  const [open, setOpen] = useState(false);

  return (
    <div className="dropdown">
      <button
        className="btn btn-secondary dropdown-toggle"
        type="button"
        onClick={() => setOpen(!open)}
      >
        <i className="bi bi-person-circle" />
      </button>

      <ul className={`dropdown-menu my-dropdown ${open ? 'show': ''}`} aria-labelledby="dropdownMenuButton1">
        <li><a className="dropdown-item" href="#"> <i className={'bi bi-person'} />  Profil</a></li>
        <li><a className="dropdown-item" href="#"> <i className={'bi bi-bag'} /> Mes commandes</a></li>
        <li><a className="dropdown-item" href="#"> <i className={'bi bi-box-arrow-right'} /> Déconnexion</a></li>
      </ul>
    </div>
  )
}