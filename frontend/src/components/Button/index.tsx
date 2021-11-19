import "./index.css";

interface ButtonProps {
  text: string;
  size?: "sm" | "lg";
  color?: "primary" | "danger";
  disabled?: boolean;
  className?: string;
  onClick: () => void;
}

export const Button = (props: ButtonProps) => {

  const { size, color, disabled, text, className, onClick } = props;

  return (
    <button
      onClick={onClick}
      disabled={disabled ?? false}
      className={`btn btn-${color ?? 'primary'} btn-${size} ${className}`}
    >
      {text}
    </button>
  );
};