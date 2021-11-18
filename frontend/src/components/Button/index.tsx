import "./index.css";

interface ButtonProps {
  text: string;
  size?: "small" | "medium" | "large";
  color?: "blue" | "red";
  disabled?: boolean;
}

export const Button = (props: ButtonProps) => {

  const { size, color, disabled, text } = props;

  return (
    <button
      disabled={disabled ?? false}
      className={`my-button ${color ?? "blue"} ${size ?? 'medium'}`}
    >
      {text}
    </button>
  );
};