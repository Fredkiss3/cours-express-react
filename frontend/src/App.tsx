import './App.css';
import { Title } from "./components/Title";
import { SubTitle } from "./components/SubTitle";
import { Link } from "./components/Link";
import { Button } from "./components/Button";

function App() {
  return (
    <div className={'container'}>
      <Title content={'Quel joli titre !!!'} />
      <SubTitle content={"Mais qu'il est beau !!"} />
      <Link href={'https://google.com'} text={"un lien"} />
      <hr/>
      <Button text={'Petit bouton'} size={'small'} />
      <hr/>
      <Button text={'Bouton normal'} size={'medium'} />
      <hr/>
      <Button text={'Grand Bouton'} size={'large'} />
      <hr/>
      <Button text={'Désactivé'} disabled={true} />
      <hr/>
      <Button text={'Bouton Rouge'} color={'red'} />
    </div>
  );
}

export default App;
