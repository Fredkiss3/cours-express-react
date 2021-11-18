import './index.css'

export const Form = (props) => {
  return (
      <form>
        {props.children}

      </form>
  )
}

export const BoutonPanier = ({children}) => {
  return (
      <Form className="panier">
        <Input />
        {/*<Toggle selectedOption={"client"} options={['client', 'vendeur']} />*/}
        <Button />
      </Form>
  )
}