import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from 'recharts';

interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
}

interface ExpensesPieChartProps {
    categories: Category[];
}

const COLORS = ['#87CFEB', '#FEDE2C', '#F4B8C8', '#98D8A3', '#FFB347', '#C9A0DC', '#FF6B6B'];

const ExpensesPieChart = ({ categories }: ExpensesPieChartProps) => {
    const pieData = categories
        .filter(cat => cat.budgetSpent > 0)
        .map((cat) => ({
            name: cat.name,
            value: cat.budgetSpent,
        }));

    return (
        <div className="pieChartContainer">
            <h2 className="chartTitle">Expenses by Category</h2>
            <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                    <Pie
                        data={pieData}
                        cx="50%"
                        cy="50%"
                        outerRadius={100}
                        dataKey="value"
                        label={({ name, percent }: any) => `${name} ${(percent * 100).toFixed(0)}%`}
                    >
                        {pieData.map((_, index) => (
                            <Cell key={index} fill={COLORS[index % COLORS.length]} />
                        ))}
                    </Pie>
                    <Tooltip formatter={(v) => v !== undefined ? `$${Number(v).toFixed(2)}` : ''} />
                </PieChart>
            </ResponsiveContainer>
        </div>
    );
};

export default ExpensesPieChart;