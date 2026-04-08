import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';

interface BudgetPieChartProps {
    totalSpent: number;
    remaining: number;
}

const BudgetPieChart = ({ totalSpent, remaining }: BudgetPieChartProps) => {
    const data = [
        { name: "Amount Spent", value: totalSpent },
        { name: "Amount Left", value: remaining > 0 ? remaining : 0 },
    ];

    return (
        <div className="pieChartContainer">
            <h2 className="chartTitle">Amount Left vs Spent</h2>
            <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                    <Pie
                        data={data}
                        cx="50%"
                        cy="50%"
                        outerRadius={100}
                        dataKey="value"
                        label={({ name, percent }: any) => `${name} ${(percent * 100).toFixed(0)}%`}
                    >
                        <Cell fill="#FF6B6B" />
                        <Cell fill="#98D8A3" />
                    </Pie>
                    <Tooltip formatter={(v) => v !== undefined ? `$${Number(v).toFixed(2)}` : ''} />
                    <Legend />
                </PieChart>
            </ResponsiveContainer>
        </div>
    );
};

export default BudgetPieChart;