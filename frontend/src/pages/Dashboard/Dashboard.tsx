import './DashboardStyle.css'

import axios from 'axios';
import { useState,useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { NavBar } from '../../components/NavBar/NavBar'
import { BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import StatCards from '../../components/DashBoardCharts/StatCards';
import CategoryBarChart from '../../components/DashBoardCharts/CategoryBarChart';
import ExpensesPieChart from '../../components/DashBoardCharts/ExpensesPieChart';
import BudgetPieChart from '../../components/DashBoardCharts/BudgetPieChart';

interface Category {
    _id: string;
    name: string;
    budgetLimit: number;
    budgetSpent: number;
}

interface Transaction {
    _id: string;
    date: string;
    categoryId: string;
    note: string;
    amount: number;
}

export const DashboardPage = () =>
{
    const [categories, setCategories] = useState<Category[]>([]);
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchData = async () => {
            const userId = localStorage.getItem('_id');
            const token = localStorage.getItem('token');
            if (!userId || !token) return;

            try {
                const catRes = await axios.get(`https://duckydollars.xyz/api/categories?userId=${userId}`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
                setCategories(catRes.data.categories);

                const transRes = await axios.get(`https://duckydollars.xyz/api/transactions?userId=${userId}`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
                setTransactions(transRes.data.transactions);
            } catch (error) {
                console.error("Failed to fetch dashboard data:", error);
            }
        };
        fetchData();
    }, []);

    const totalBudget = categories.reduce((sum, cat) => sum + cat.budgetLimit, 0);
    const totalSpent = categories.reduce((sum, cat) => sum + cat.budgetSpent, 0);
    const remaining = totalBudget - totalSpent;

    return(
        <>
            <NavBar />
            <div className="dashDiv">
                <h1 id="dashTitle">Ducky Dashboard</h1>

                <StatCards
                    totalSpent={totalSpent}
                    totalBudget={totalBudget}
                    remaining={remaining}
                    numTransactions={transactions.length}
                />

                <CategoryBarChart categories={categories} />

                <div className="pieChartsRow">
                    <ExpensesPieChart categories={categories} />
                    <BudgetPieChart totalSpent={totalSpent} remaining={remaining} />
                </div>

                <div className="dashFooter">
                    <button id="editBudgetBtn" onClick={() => navigate('/budget')}>Edit Budget</button>
                </div>

                <div className="recentTransactions">
                    <h2>Recently Added Transactions</h2>

                    <table id="recentTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Category</th>
                                <th>Note</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            {[...transactions]
                                .sort((a, b) => {
                                    const timeA = parseInt(a._id.substring(0, 8), 16);
                                    const timeB = parseInt(b._id.substring(0, 8), 16);
                                    return timeB - timeA;
                                })
                                .slice(0, 5)
                                .map((t) => {
                                    const category = categories.find(cat => cat._id === t.categoryId);
                                    return (
                                        <tr key={t._id}>
                                            <td>{new Date(t.date).toLocaleDateString()}</td>
                                            <td>{category ? category.name : 'Unknown'}</td>
                                            <td>{t.note}</td>
                                            <td>${t.amount.toFixed(2)}</td>
                                        </tr>
                                    );
                                })}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};