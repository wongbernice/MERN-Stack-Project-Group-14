import { BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer, Cell } from 'recharts';

interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
}

interface CategoryBarChartProps {
    categories: Category[];
}

//Add a feature where when the user goes over budget, so when the yellow overlaps the blue, the bar goes red

const CategoryBarChart = ({ categories }: CategoryBarChartProps) => {
    const barData = categories.map((cat) => ({
        name: cat.name,
        "Amount Spent": cat.budgetSpent,
        "Remaining": Math.max(cat.budgetLimit - cat.budgetSpent, 0),
        overBudget: cat.budgetSpent > cat.budgetLimit,
        overage: Math.max(cat.budgetSpent - cat.budgetLimit, 0),
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
                    <Tooltip formatter={(value, name, props) => {
                        if (name === "Remaining" && props.payload.overBudget) {
                            return [`-$${props.payload.overage.toFixed(2)}`, "Over Budget"];
                        }
                        return [`$${Number(value).toFixed(2)}`, name];
                    }} />
                    <Legend />
                    <Bar dataKey="Amount Spent" stackId="a">
                        {barData.map((entry, index) => (
                            <Cell key={index} fill={entry.overBudget ? "#FF4C4C" : "#FEDE2C"} />
                        ))}
                    </Bar>
                    <Bar dataKey="Remaining" fill="#87CFEB" stackId="a">
                        {barData.map((entry, index) => (
                            <Cell key={index} fill={entry.overBudget ? "#FF9999" : "#87CFEB"} />
                        ))}
                    </Bar>
                </BarChart>
            </ResponsiveContainer>
        </div>
    );
};

export default CategoryBarChart;