interface LinkProps {
  href: string;
  text: string;
}

export const Link = (props: LinkProps) => {

  const {href, text} = props;

  return (
    <a href={href}>{text}</a>
  )
}