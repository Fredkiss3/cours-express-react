
interface SubTitleProps {
  content: string;
  className?: string;
}

export const SubTitle = (props: SubTitleProps) => {
  return (
    <h2 className={props.className}>{props.content}</h2>
  )
}