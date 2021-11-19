interface SelectQuantityProps {
    quantity: number;
    maxQuantity: number;
    onChange: (quantity: number) => void;
}

export function SelectQuantity(props: SelectQuantityProps) {
    const { quantity, maxQuantity, onChange } = props;

    return (
        <>
            <label htmlFor="staticEmail" className="col-sm-2 col-form-label">
                Quantité
            </label>
            <div className="col-sm-10">
                <select
                    value={quantity}
                    onChange={(e) => onChange(Number(e.target.value))}
                >
                    {Array.from(Array(maxQuantity).keys()).map((i) => (
                        <option key={i} value={i + 1}>
                            {i + 1}
                        </option>
                    ))}
                </select>
            </div>
        </>
    );
}
