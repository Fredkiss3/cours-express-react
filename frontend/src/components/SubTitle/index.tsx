
interface SubTitleProps {
  content: string;
}

export const SubTitle = (props: SubTitleProps) => {
  return (
    <h2>{props.content}</h2>
  )
}