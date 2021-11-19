import "./index.css";

interface IconButtonProps {
  text: string;
  size?: "sm" | "lg";
  color?: "primary" | "danger";
  disabled?: boolean;
  className?: string;
  onClick: () => void;
  icon: string;
}

export const IconButton = (props: IconButtonProps) => {

  const { size, color, disabled, text, className, onClick, icon } = props;

  return (
    <button
      onClick={onClick}
      disabled={disabled ?? false}
      className={`btn btn-${color ?? 'primary'} btn-${size} ${className} d-flex gap-2`}
    >
      <i className={`bi bi-${icon}`} />

      {text}
    </button>
  );
};