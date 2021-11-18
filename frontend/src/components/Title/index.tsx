import './index.css'

interface TitleProps {
  content: string;
}

export const Title = (props: TitleProps) => {
  return (
    <h1>{props.content}</h1>
  )
}
