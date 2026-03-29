import { BrowserRouter, Routes, Route} from 'react-router-dom'
import { Index }  from './pages/Index/Index' // will change later
import { LoginPage } from './pages/Login/Login'
import { SignUpPage } from './pages/SignUp/SignUp'
import { DashboardPage } from './pages/Dashboard/Dashboard'
import { TransactionsPage } from './pages/Transactions/Transactions'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Index />} /> {/*will change later */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signUp" element={<SignUpPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/transactions" element={<TransactionsPage />} />
        <Route path="*" element={<h1>404: Page Not Found</h1>} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;