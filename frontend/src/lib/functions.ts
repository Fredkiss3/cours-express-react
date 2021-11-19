export function floatToEUR(value: number): string {
    // Format to two decimals with Internationalized format in French
    return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: 'EUR',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    }).format(value);
}
