import { BrowserRouter, Routes, Route} from 'react-router-dom'
import { Index }  from './pages/Index/Index' // will change later
import { LoginPage } from './pages/Login/Login'
import { ResetPasswordPage } from './pages/ResetPassword/ResetPassword'
import { SignUpPage } from './pages/SignUp/SignUp'
import { VerifyPage } from './pages/Verify/Verify'
import { DashboardPage } from './pages/Dashboard/Dashboard'
import { TransactionsPage } from './pages/Transactions/Transactions'
import { BudgetPage } from './pages/Budget/Budget'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Index />} /> {/*will change later */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/resetPassword" element={<ResetPasswordPage />} />
        <Route path="/verify" element={<VerifyPage />} />
        <Route path="/signUp" element={<SignUpPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/transactions" element={<TransactionsPage />} />
        <Route path="/budget" element={<BudgetPage />} />
        <Route path="*" element={<h1>404: Page Not Found</h1>} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;