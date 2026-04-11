import { BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from 'recharts';

interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
}

interface CategoryBarChartProps {
    categories: Category[];
}

const CategoryBarChart = ({ categories }: CategoryBarChartProps) => {
    const barData = categories.map((cat) => ({
        name: cat.name,
        "Amount Spent": cat.budgetSpent,
        "Remaining": Math.max(cat.budgetLimit - cat.budgetSpent, 0),
    }));

    return (
        <div className="chartContainer">
            <h2 className="chartTitle">Monthly Spending</h2>
            <ResponsiveContainer width="100%" height={350}>
                <BarChart
                    layout="vertical"
                    data={barData}
                    margin={{ top: 10, right: 30, left: 60, bottom: 10 }}
                    barSize={18}
                    barGap={0}
                    barCategoryGap={30}
                >
                    <XAxis type="number" tickFormatter={(v) => `$${v}`} />
                    <YAxis type="category" dataKey="name" />
                    <Tooltip formatter={(v) => v !== undefined ? `$${Number(v).toFixed(2)}` : ''} />
                    <Legend />
                    <Bar dataKey="Amount Spent" fill="#FEDE2C" stackId="a" />
                    <Bar dataKey="Remaining" fill="#87CFEB" stackId="a" />
                </BarChart>
            </ResponsiveContainer>
        </div>
    );
};

export default CategoryBarChart;