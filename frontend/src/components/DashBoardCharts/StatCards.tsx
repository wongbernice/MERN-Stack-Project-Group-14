
interface StatCardsProps {
    totalSpent: number;
    totalBudget: number;
    remaining: number;
    numTransactions: number;
}

const StatCards = ({ totalSpent, totalBudget, remaining, numTransactions }: StatCardsProps) => {
    return (
        <div className="statCards">
            <div className="card" id="spentCard">
                <p className="cardLabel">Total Spent</p>
                <p className="cardAmount">${totalSpent.toFixed(2)}</p>
                <p className="cardSub">this month</p>
            </div>
            <div className="card" id="budgetCard">
                <p className="cardLabel">Total Budget</p>
                <p className="cardAmount">${totalBudget.toFixed(2)}</p>
                <p className="cardSub">this month</p>
            </div>
            <div className="card" id="remainingCard">
                <p className="cardLabel">Remaining</p>
                <p className="cardAmount">${remaining.toFixed(2)}</p>
                <p className="cardSub">this month</p>
            </div>
            <div className="card" id="expensesCard">
                <p className="cardLabel"># of Expenses</p>
                <p className="cardAmount">{numTransactions}</p>
                <p className="cardSub">transactions this month</p>
            </div>
        </div>
    );
};

export default StatCards;