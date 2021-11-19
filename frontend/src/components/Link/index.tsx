interface LinkProps {
  href: string;
  text: string;
  className?: string;
}

export const Link = (props: LinkProps) => {

  const {href, text, className} = props;

  return (
    <a href={href} className={`${className ?? ''}`}>{text}</a>
  )
}