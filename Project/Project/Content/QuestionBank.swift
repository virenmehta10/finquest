//
//  QuestionBank.swift
//  Project
//
//  Seed content for modules and lessons
//

import Foundation

enum QuestionBank {
    static let dcfSection1: [Question] = [
        Question(
            prompt: "The core purpose of a DCF is to:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Value a company based on its projected cash flows", isCorrect: true),
                AnswerChoice(text: "Compare accounting profits year to year", isCorrect: false),
                AnswerChoice(text: "Rank companies by market capitalization", isCorrect: false),
                AnswerChoice(text: "Measure book value growth", isCorrect: false)
            ],
            explanation: "DCF (Discounted Cash Flow) values a company by forecasting future cash flows and discounting them back to present value using an appropriate discount rate. It's an intrinsic valuation method."
        ),
        Question(
            prompt: "What does \"intrinsic valuation\" mean in a DCF context?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Valuing a company based on peer multiples", isCorrect: false),
                AnswerChoice(text: "Using only market data to determine value", isCorrect: false),
                AnswerChoice(text: "Valuing a company using its own projected cash flows", isCorrect: true),
                AnswerChoice(text: "Relying on analyst consensus", isCorrect: false)
            ],
            explanation: "Intrinsic valuation means valuing based on the company's own fundamentals (projected cash flows), not on what the market is paying for similar companies. It's bottom-up, company-specific."
        ),
        Question(
            prompt: "Which cash flow metric is typically used in an unlevered DCF?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Free Cash Flow to Equity", isCorrect: false),
                AnswerChoice(text: "Net Income", isCorrect: false),
                AnswerChoice(text: "Unlevered Free Cash Flow (UFCF)", isCorrect: true),
                AnswerChoice(text: "Operating Cash Flow", isCorrect: false)
            ],
            explanation: "Unlevered DCF uses UFCF (also called Free Cash Flow to the Firm), which represents cash available to all investors (debt + equity) before financing effects. Discounted at WACC."
        ),
        Question(
            prompt: "What does \"discounting\" cash flows mean?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Adjusting them for inflation", isCorrect: false),
                AnswerChoice(text: "Increasing them to reflect growth", isCorrect: false),
                AnswerChoice(text: "Subtracting depreciation", isCorrect: false),
                AnswerChoice(text: "Reducing future cash flows to their present value", isCorrect: true)
            ],
            explanation: "Discounting adjusts future cash flows to present value using the time value of money principle: $1 today is worth more than $1 tomorrow. Formula: PV = FCF / (1 + r)^t."
        ),
        Question(
            prompt: "The key relationship driving all DCFs is:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Company Value = Assets – Liabilities", isCorrect: false),
                AnswerChoice(text: "EV = Equity + Debt – Cash", isCorrect: false),
                AnswerChoice(text: "Company Value = Cash Flow / (Discount Rate – Growth Rate)", isCorrect: true),
                AnswerChoice(text: "Company Value = EPS × P/E", isCorrect: false)
            ],
            explanation: "This is the Gordon Growth Model (perpetuity formula) that underlies terminal value calculations: Value = CF × (1+g) / (r - g). Foundation of DCF valuation."
        ),
        Question(
            prompt: "The discount rate in an unlevered DCF is usually:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cost of Equity", isCorrect: false),
                AnswerChoice(text: "Weighted Average Cost of Capital (WACC)", isCorrect: true),
                AnswerChoice(text: "Cost of Debt", isCorrect: false),
                AnswerChoice(text: "Tax rate × Beta", isCorrect: false)
            ],
            explanation: "Unlevered DCF uses WACC as the discount rate because UFCF represents cash flows to all investors (debt + equity). WACC reflects the blended required return for all capital providers."
        ),
        Question(
            prompt: "The \"explicit forecast period\" usually covers:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "5–10 years", isCorrect: true),
                AnswerChoice(text: "3 years", isCorrect: false),
                AnswerChoice(text: "1 year", isCorrect: false),
                AnswerChoice(text: "20+ years", isCorrect: false)
            ],
            explanation: "Standard explicit forecast period is 5-10 years—long enough for the company to reach steady-state operations, short enough to be reasonably predictable. After that, terminal value captures remaining value."
        ),
        Question(
            prompt: "The terminal value typically represents:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The company's current year value", isCorrect: false),
                AnswerChoice(text: "The book value of assets", isCorrect: false),
                AnswerChoice(text: "The liquidation value", isCorrect: false),
                AnswerChoice(text: "The continuing value beyond the forecast period", isCorrect: true)
            ],
            explanation: "Terminal Value represents the company's value from the end of the explicit forecast period into perpetuity. It typically accounts for 60-80% of total enterprise value in most DCFs."
        ),
        Question(
            prompt: "Why do you use Free Cash Flow instead of Net Income?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Net Income ignores depreciation", isCorrect: false),
                AnswerChoice(text: "Net Income includes non-cash items", isCorrect: false),
                AnswerChoice(text: "FCF reflects true cash available to investors", isCorrect: true),
                AnswerChoice(text: "FCF is always higher", isCorrect: false)
            ],
            explanation: "FCF represents actual cash generated that's available to investors after reinvestment needs (CapEx, working capital). Net Income includes non-cash items and doesn't account for capital requirements."
        ),
        Question(
            prompt: "The DCF is most useful when:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The company has stable, predictable cash flows", isCorrect: true),
                AnswerChoice(text: "The company has negative FCF", isCorrect: false),
                AnswerChoice(text: "The company is in early-stage hypergrowth", isCorrect: false),
                AnswerChoice(text: "There are no peers to benchmark", isCorrect: false)
            ],
            explanation: "DCF works best with mature, stable companies where cash flows are predictable. Volatile or negative FCF makes forecasting unreliable. Early-stage companies lack the track record needed for credible projections."
        )
    ]

    static let dcfSection2: [Question] = [
        Question(
            prompt: "Unlevered Free Cash Flow (UFCF) equals:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EBIT × (1 – Tax Rate) + D&A – CapEx – Change in WC", isCorrect: true),
                AnswerChoice(text: "Net Income + D&A – CapEx – Change in WC", isCorrect: false),
                AnswerChoice(text: "EBITDA – Taxes – CapEx – Debt Repayment", isCorrect: false),
                AnswerChoice(text: "CFO – CFI + Dividends", isCorrect: false)
            ],
            explanation: "UFCF = NOPAT + D&A - CapEx - ΔWC, where NOPAT = EBIT × (1-Tax Rate). Start with after-tax operating profit, add back non-cash D&A, subtract investments in assets and working capital."
        ),
        Question(
            prompt: "Which non-cash item is excluded when calculating UFCF?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Depreciation", isCorrect: false),
                AnswerChoice(text: "Deferred Taxes", isCorrect: false),
                AnswerChoice(text: "Stock-Based Compensation", isCorrect: true),
                AnswerChoice(text: "Amortization", isCorrect: false)
            ],
            explanation: "Stock-based compensation is excluded from UFCF calculation (though it's a real expense on the Income Statement). It's non-cash, but dilution is captured separately in share count adjustments."
        ),
        Question(
            prompt: "What is NOPAT?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Net Operating Profit After Tax", isCorrect: true),
                AnswerChoice(text: "Net Output Per Asset Turnover", isCorrect: false),
                AnswerChoice(text: "Net Other Profit Adjusted Total", isCorrect: false),
                AnswerChoice(text: "Non-Operating Profit At Time", isCorrect: false)
            ],
            explanation: "NOPAT = Net Operating Profit After Tax = EBIT × (1 - Tax Rate). It's operating profit after taxes but before financing costs (interest). Starting point for UFCF calculation."
        ),
        Question(
            prompt: "When projecting FCF, which sections of the financial statements are ignored?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Operating cash flows", isCorrect: false),
                AnswerChoice(text: "Financing and most investing cash flows", isCorrect: true),
                AnswerChoice(text: "Income statement", isCorrect: false),
                AnswerChoice(text: "Working capital", isCorrect: false)
            ],
            explanation: "FCF projection ignores financing activities (debt issuance/repayment, dividends) and non-operational investing (M&A, investments). Focus on core operating performance and maintenance capex."
        ),
        Question(
            prompt: "In WACC, the after-tax Cost of Debt is calculated as:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Pre-tax rate × (1 – Tax Rate)", isCorrect: true),
                AnswerChoice(text: "Pre-tax rate × (1 + Tax Rate)", isCorrect: false),
                AnswerChoice(text: "Coupon × (Tax Rate)", isCorrect: false),
                AnswerChoice(text: "Interest expense ÷ total debt", isCorrect: false)
            ],
            explanation: "After-tax cost of debt = rd × (1 - T). Interest expense is tax-deductible, so the effective cost is reduced by the tax benefit. This reflects the tax shield provided by debt."
        ),
        Question(
            prompt: "The Cost of Equity is typically estimated using:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Dividend Discount Model", isCorrect: false),
                AnswerChoice(text: "Company's coupon rate", isCorrect: false),
                AnswerChoice(text: "EBIT ÷ Equity Value", isCorrect: false),
                AnswerChoice(text: "CAPM: Risk-Free Rate + Beta × Equity Risk Premium", isCorrect: true)
            ],
            explanation: "CAPM (Capital Asset Pricing Model) is the most common method: Cost of Equity = Rf + β(Rm - Rf). It estimates required return based on risk-free rate plus a risk premium adjusted for company-specific volatility."
        ),
        Question(
            prompt: "What happens to WACC when a company adds moderate debt?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Always increases", isCorrect: false),
                AnswerChoice(text: "Always decreases", isCorrect: false),
                AnswerChoice(text: "Usually decreases at first, then increases past a point", isCorrect: true),
                AnswerChoice(text: "Never changes", isCorrect: false)
            ],
            explanation: "Initially, adding debt lowers WACC (debt is cheaper than equity, provides tax shield). But excessive debt increases financial risk, raising cost of equity significantly, eventually increasing WACC. U-shaped curve."
        ),
        Question(
            prompt: "Beta measures:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Operating leverage", isCorrect: false),
                AnswerChoice(text: "Volatility of the company relative to the market", isCorrect: true),
                AnswerChoice(text: "Systematic accounting risk", isCorrect: false),
                AnswerChoice(text: "Dividend yield variability", isCorrect: false)
            ],
            explanation: "Beta measures systematic risk—how much the stock moves relative to the overall market. β > 1 means more volatile than market; β < 1 means less volatile. Used in CAPM."
        ),
        Question(
            prompt: "What is the main reason we unlever and relever Beta?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To remove the impact of capital structure differences", isCorrect: true),
                AnswerChoice(text: "To normalize for depreciation", isCorrect: false),
                AnswerChoice(text: "To match industry growth rates", isCorrect: false),
                AnswerChoice(text: "To calculate Cost of Debt", isCorrect: false)
            ],
            explanation: "Unlevering removes the effect of a company's specific debt/equity mix to get pure business risk. Relevering adjusts to the target capital structure. Enables apples-to-apples comparison across companies with different leverage."
        ),
        Question(
            prompt: "If risk-free rates rise, what happens to a DCF valuation (ceteris paribus)?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases", isCorrect: false),
                AnswerChoice(text: "Decreases", isCorrect: true),
                AnswerChoice(text: "Stays the same", isCorrect: false),
                AnswerChoice(text: "Doubles", isCorrect: false)
            ],
            explanation: "Higher risk-free rate → higher cost of equity (via CAPM) → higher WACC → higher discount rate → lower present value of cash flows → lower DCF valuation."
        )
    ]

    static let dcfSection3: [Question] = [
        Question(
            prompt: "The Gordon Growth formula for Terminal Value is:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "TV = FCF × (1 – g) / (r – g)", isCorrect: false),
                AnswerChoice(text: "TV = FCF × (1 + g) / (r – g)", isCorrect: true),
                AnswerChoice(text: "TV = EBITDA × Exit Multiple", isCorrect: false),
                AnswerChoice(text: "TV = FCF / r", isCorrect: false)
            ],
            explanation: "Gordon Growth (Perpetuity) formula: TV = FCF(Year N+1) × (1+g) / (r-g) = FCF(Year N) × (1+g) / (r-g). Assumes constant growth forever. \"r\" is WACC, \"g\" is perpetual growth rate."
        ),
        Question(
            prompt: "The Terminal Growth Rate (g) should usually be:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Negative", isCorrect: false),
                AnswerChoice(text: "5–10%", isCorrect: false),
                AnswerChoice(text: "Below GDP or inflation rate (≈1–3%)", isCorrect: true),
                AnswerChoice(text: "Equal to EBITDA growth", isCorrect: false)
            ],
            explanation: "Terminal growth must be conservative—can't grow faster than the economy forever. Typically 2-3% (around long-term GDP/inflation). Higher rates imply company eventually becomes the entire economy."
        ),
        Question(
            prompt: "Using an exit multiple to calculate TV is also known as:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Gordon Growth method", isCorrect: false),
                AnswerChoice(text: "Multiples method", isCorrect: true),
                AnswerChoice(text: "Market premium method", isCorrect: false),
                AnswerChoice(text: "Perpetuity formula", isCorrect: false)
            ],
            explanation: "Exit Multiple Method: TV = Final Year EBITDA × Exit Multiple (e.g., peer average EV/EBITDA). Alternative to Gordon Growth. Relies on market-based valuation rather than perpetual growth assumption."
        ),
        Question(
            prompt: "Why is it important to cross-check terminal value results?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To confirm D&A assumptions", isCorrect: false),
                AnswerChoice(text: "To ensure implied growth and multiple are realistic", isCorrect: true),
                AnswerChoice(text: "To double FCF accuracy", isCorrect: false),
                AnswerChoice(text: "To match peer book value", isCorrect: false)
            ],
            explanation: "If using Gordon Growth, calculate implied exit multiple. If using exit multiple, calculate implied growth rate. Ensure both are reasonable and consistent with long-term expectations to avoid over/undervaluation."
        ),
        Question(
            prompt: "Which portion of the DCF typically contributes most to total Enterprise Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Change in Working Capital", isCorrect: false),
                AnswerChoice(text: "Terminal Value", isCorrect: true),
                AnswerChoice(text: "Discounted FCF in forecast period", isCorrect: false),
                AnswerChoice(text: "Deferred tax adjustment", isCorrect: false)
            ],
            explanation: "Terminal Value typically represents 60-80% of total EV in most DCFs because it captures all value from the end of the forecast period into perpetuity—often decades of cash flows."
        ),
        Question(
            prompt: "If the terminal multiple is too high, the implied terminal growth rate will be:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Too low", isCorrect: false),
                AnswerChoice(text: "Too high", isCorrect: true),
                AnswerChoice(text: "Unchanged", isCorrect: false),
                AnswerChoice(text: "Negative", isCorrect: false)
            ],
            explanation: "Higher exit multiple → higher terminal value → implies higher perpetual growth rate to justify that value. Cross-checking helps identify unrealistic assumptions. Use both methods to triangulate reasonable TV."
        ),
        Question(
            prompt: "What's the effect of a 1% increase in discount rate vs. 1% increase in revenue growth?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Revenue has greater impact", isCorrect: false),
                AnswerChoice(text: "Discount rate has greater impact", isCorrect: true),
                AnswerChoice(text: "Equal effect", isCorrect: false),
                AnswerChoice(text: "Neither affects EV", isCorrect: false)
            ],
            explanation: "DCF is highly sensitive to the discount rate because it affects every period's cash flow exponentially. Small WACC changes materially impact valuation more than revenue growth changes, especially for distant cash flows."
        ),
        Question(
            prompt: "The mid-year convention adjusts for:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Mid-year dividend payouts", isCorrect: false),
                AnswerChoice(text: "Cash flow timing within the year", isCorrect: true),
                AnswerChoice(text: "Deferred tax reversals", isCorrect: false),
                AnswerChoice(text: "Stub periods", isCorrect: false)
            ],
            explanation: "Mid-year convention assumes cash flows occur at the midpoint of each year (not year-end), slightly increasing present value. More realistic than assuming all cash comes on December 31st. Discount by t-0.5 instead of t."
        ),
        Question(
            prompt: "Stub periods in a DCF occur when:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The company has no debt", isCorrect: false),
                AnswerChoice(text: "Valuation date is not fiscal year-end", isCorrect: true),
                AnswerChoice(text: "Discount rate is negative", isCorrect: false),
                AnswerChoice(text: "There are missing cash flows", isCorrect: false)
            ],
            explanation: "Stub period = partial year when valuation date doesn't align with fiscal year-end. E.g., valuing on June 30 creates a 6-month stub before Year 1 begins. Requires adjusting discount periods accordingly."
        ),
        Question(
            prompt: "Why can a \"normalized terminal year\" be necessary?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To account for unsustainable trends (e.g., one-time events)", isCorrect: true),
                AnswerChoice(text: "To extend projections", isCorrect: false),
                AnswerChoice(text: "To adjust beta", isCorrect: false),
                AnswerChoice(text: "To remove working capital", isCorrect: false)
            ],
            explanation: "Terminal year should represent steady-state, sustainable operations. Remove one-time items, unusual margin spikes, or temporary factors to ensure the perpetuity assumption is reasonable. Normalize before applying growth formula."
        )
    ]

    static let dcfSection4: [Question] = [
        Question(
            prompt: "A company has FCF = $100, WACC = 10%, g = 2%. What's its Terminal Value (Gordon Growth)?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "$800", isCorrect: false),
                AnswerChoice(text: "$1,000", isCorrect: false),
                AnswerChoice(text: "$1,275", isCorrect: true),
                AnswerChoice(text: "$1,500", isCorrect: false)
            ],
            explanation: "TV = FCF × (1+g) / (WACC-g) = $100 × 1.02 / (0.10 - 0.02) = $102 / 0.08 = $1,275."
        ),
        Question(
            prompt: "If WACC rises while Terminal Growth falls, what happens to EV?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases", isCorrect: false),
                AnswerChoice(text: "Decreases sharply", isCorrect: true),
                AnswerChoice(text: "Stays constant", isCorrect: false),
                AnswerChoice(text: "Becomes infinite", isCorrect: false)
            ],
            explanation: "Both changes work in the same direction. Higher WACC (denominator increases) and lower growth (numerator decreases) both reduce terminal value dramatically: TV = FCF(1+g)/(WACC-g). Double negative impact on valuation."
        ),
        Question(
            prompt: "Why do you exclude interest expense when calculating UFCF?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To reflect value available to all investors", isCorrect: true),
                AnswerChoice(text: "To simplify accounting", isCorrect: false),
                AnswerChoice(text: "Because it's a non-cash charge", isCorrect: false),
                AnswerChoice(text: "To reduce volatility", isCorrect: false)
            ],
            explanation: "UFCF excludes interest because we're valuing the entire firm (debt + equity) before financing decisions. Interest is a financing outflow to debt holders, not an operating expense. WACC already accounts for debt cost."
        ),
        Question(
            prompt: "Which factor would increase WACC?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Lower Beta", isCorrect: false),
                AnswerChoice(text: "Higher Equity Risk Premium", isCorrect: true),
                AnswerChoice(text: "Lower Risk-Free Rate", isCorrect: false),
                AnswerChoice(text: "Higher tax rate", isCorrect: false)
            ],
            explanation: "Higher Equity Risk Premium → higher Cost of Equity (via CAPM) → higher WACC. WACC = (E/V)×Re + (D/V)×Rd×(1-T). Increasing the equity risk premium directly raises Re."
        ),
        Question(
            prompt: "Which assumption change impacts DCF most?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "CAPEX – 1%", isCorrect: false),
                AnswerChoice(text: "Tax Rate – 1%", isCorrect: false),
                AnswerChoice(text: "WACC +1%", isCorrect: true),
                AnswerChoice(text: "Inventory +1%", isCorrect: false)
            ],
            explanation: "WACC has the largest impact on DCF valuation. It's the denominator in every period's discount calculation, so changes compound exponentially. Small WACC adjustments create material valuation swings."
        ),
        Question(
            prompt: "Why does more debt initially decrease WACC?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Because interest is tax deductible", isCorrect: true),
                AnswerChoice(text: "Because cost of equity falls", isCorrect: false),
                AnswerChoice(text: "Because cost of debt equals inflation", isCorrect: false),
                AnswerChoice(text: "Because leverage increases growth", isCorrect: false)
            ],
            explanation: "Debt provides a tax shield (interest is tax-deductible), making after-tax cost of debt lower than cost of equity. Initially, replacing expensive equity with cheaper debt reduces overall WACC."
        ),
        Question(
            prompt: "Why can WACC later increase when too much debt is added?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Equity investors demand higher returns due to risk", isCorrect: true),
                AnswerChoice(text: "Beta falls", isCorrect: false),
                AnswerChoice(text: "Tax rate drops", isCorrect: false),
                AnswerChoice(text: "Interest expense is ignored", isCorrect: false)
            ],
            explanation: "Excessive leverage increases financial risk. Equity holders demand higher returns (cost of equity rises) to compensate for increased risk of financial distress. Eventually, rising Re outweighs tax benefits, increasing WACC."
        ),
        Question(
            prompt: "Why is a DCF unreliable for early-stage companies?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "They lack positive, predictable cash flows", isCorrect: true),
                AnswerChoice(text: "Their betas are too low", isCorrect: false),
                AnswerChoice(text: "Their taxes are irregular", isCorrect: false),
                AnswerChoice(text: "They don't use WACC", isCorrect: false)
            ],
            explanation: "Early-stage companies typically have negative or highly volatile cash flows, making it nearly impossible to create reliable projections. Lack of operating history means no basis for forecasting. Better to use market-based methods."
        ),
        Question(
            prompt: "In an Adjusted Present Value (APV) model, what is added to the unlevered DCF result?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Tax shield from debt", isCorrect: true),
                AnswerChoice(text: "Cost of equity", isCorrect: false),
                AnswerChoice(text: "Interest expense", isCorrect: false),
                AnswerChoice(text: "Dividend payout", isCorrect: false)
            ],
            explanation: "APV separates operating value from financing effects. APV = Unlevered Firm Value (discounted at unlevered cost of equity) + PV(Tax Shields from Interest). Useful when capital structure changes significantly."
        ),
        Question(
            prompt: "You find that 90% of your firm's EV comes from terminal value. What should you do?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Accept it; normal for DCFs", isCorrect: false),
                AnswerChoice(text: "Extend projection period or reassess assumptions", isCorrect: true),
                AnswerChoice(text: "Increase WACC", isCorrect: false),
                AnswerChoice(text: "Set growth to zero", isCorrect: false)
            ],
            explanation: "If TV dominates (>80%), the valuation is too dependent on distant assumptions. Extend explicit forecast to reach steady state, validate terminal assumptions, present sensitivity analysis. Increases credibility and reduces assumption risk."
        )
    ]

    static let lboSection1: [Question] = [
        Question(
            prompt: "What is the primary goal of a private equity firm in an LBO?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Hold a company forever and collect dividends", isCorrect: false),
                AnswerChoice(text: "Acquire, improve, and sell for a high return", isCorrect: true),
                AnswerChoice(text: "Merge with a strategic buyer", isCorrect: false),
                AnswerChoice(text: "Issue stock to repay debt", isCorrect: false)
            ],
            explanation: "PE firms use LBOs to acquire companies, improve operations/profitability, and exit within 3-7 years at a higher valuation. Goal is generating high returns (IRR >20%) for limited partners through buy-improve-sell strategy."
        ),
        Question(
            prompt: "In an LBO, most of the purchase is financed using:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Debt and equity", isCorrect: true),
                AnswerChoice(text: "Only cash", isCorrect: false),
                AnswerChoice(text: "Only equity", isCorrect: false),
                AnswerChoice(text: "Stock and cash", isCorrect: false)
            ],
            explanation: "LBOs use significant debt (typically 60-80%) and equity (20-40%) to finance the purchase. The leverage magnifies returns to equity investors if the deal performs well."
        ),
        Question(
            prompt: "Why do PE firms prefer to use high leverage in buyouts?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "It guarantees higher returns", isCorrect: false),
                AnswerChoice(text: "It reduces default risk", isCorrect: false),
                AnswerChoice(text: "It amplifies potential returns on equity", isCorrect: true),
                AnswerChoice(text: "It minimizes due diligence", isCorrect: false)
            ],
            explanation: "Leverage magnifies returns—using less equity means higher IRR if successful. But it's a double-edged sword: leverage also magnifies losses if the deal underperforms. It's about amplifying outcomes, not guaranteeing them."
        ),
        Question(
            prompt: "What does \"leverage amplifies returns\" mean?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "It increases IRR regardless of outcome", isCorrect: false),
                AnswerChoice(text: "It ensures stable returns", isCorrect: false),
                AnswerChoice(text: "It doubles profits in every case", isCorrect: false),
                AnswerChoice(text: "It increases returns if the deal performs well and worsens them if not", isCorrect: true)
            ],
            explanation: "Leverage works both ways. Good deal → magnified returns (less equity invested, same value creation). Bad deal → magnified losses (fixed debt payments strain cash flow). It's amplification, not guaranteed improvement."
        ),
        Question(
            prompt: "Which of the following best defines an LBO?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Equity-financed merger", isCorrect: false),
                AnswerChoice(text: "Public equity investment", isCorrect: false),
                AnswerChoice(text: "Debt-financed acquisition by a PE firm", isCorrect: true),
                AnswerChoice(text: "IPO-funded buyout", isCorrect: false)
            ],
            explanation: "LBO = Leveraged Buyout. A PE firm acquires a company using significant debt (leverage) financing. The target company's cash flows service the debt. Classic financial engineering transaction."
        ),
        Question(
            prompt: "Who provides the debt used in most LBOs?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Retail investors", isCorrect: false),
                AnswerChoice(text: "Government", isCorrect: false),
                AnswerChoice(text: "Banks and institutional lenders", isCorrect: true),
                AnswerChoice(text: "Company employees", isCorrect: false)
            ],
            explanation: "LBO debt comes from banks (senior secured loans), institutional lenders (term loans), and bond investors (high-yield bonds). Lenders are secured by the target company's assets and cash flows."
        ),
        Question(
            prompt: "Which statement about leverage is true?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "It makes good deals better and bad deals worse", isCorrect: true),
                AnswerChoice(text: "It always boosts IRR", isCorrect: false),
                AnswerChoice(text: "It lowers equity returns", isCorrect: false),
                AnswerChoice(text: "It eliminates financial risk", isCorrect: false)
            ],
            explanation: "Leverage is neutral—it amplifies outcomes. Successful LBO → high equity returns due to low equity invested. Failed LBO → equity wiped out while debt remains. Magnification works in both directions."
        ),
        Question(
            prompt: "What does \"home-flipping\" analogy in LBOs illustrate?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Buying and living in a house", isCorrect: false),
                AnswerChoice(text: "Buying, improving, and reselling", isCorrect: true),
                AnswerChoice(text: "Renting forever", isCorrect: false),
                AnswerChoice(text: "Buying for dividends", isCorrect: false)
            ],
            explanation: "Like flipping houses: buy undervalued asset, improve it (renovate/improve operations), sell for profit. PE firms buy companies, increase EBITDA through operational improvements, then exit at higher multiple."
        ),
        Question(
            prompt: "Who ultimately repays the LBO debt?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The PE fund investors", isCorrect: false),
                AnswerChoice(text: "The acquired company's cash flows", isCorrect: true),
                AnswerChoice(text: "The holding company owners personally", isCorrect: false),
                AnswerChoice(text: "The government", isCorrect: false)
            ],
            explanation: "The target company's operations generate cash flow to service and repay the debt—not the PE firm itself. Debt is on the portfolio company's balance sheet, secured by its assets."
        ),
        Question(
            prompt: "The \"holding company\" structure in an LBO ensures:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Debt sits at portfolio company level, not PE firm level", isCorrect: true),
                AnswerChoice(text: "Debt sits on the fund's balance sheet", isCorrect: false),
                AnswerChoice(text: "Interest is tax-free", isCorrect: false),
                AnswerChoice(text: "Equity is publicly traded", isCorrect: false)
            ],
            explanation: "Debt is ring-fenced at the portfolio company level. If the deal fails, the PE firm only loses its equity investment—no recourse to the fund's other capital. Protects the PE firm and other portfolio companies."
        )
    ]

    static let lboSection2: [Question] = [
        Question(
            prompt: "The four main steps in a simple LBO model are:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Purchase → Tax → Exit → Dividend", isCorrect: false),
                AnswerChoice(text: "Valuation → IPO → Tax → Exit", isCorrect: false),
                AnswerChoice(text: "DCF → WACC → NPV → Exit", isCorrect: false),
                AnswerChoice(text: "Assumptions → Cash Flow → Debt Paydown → Exit", isCorrect: true)
            ],
            explanation: "Simple LBO flow: (1) Set assumptions (purchase price, leverage, EBITDA growth), (2) Project cash flows, (3) Model debt repayment schedule, (4) Calculate exit value and returns (IRR, MoM)."
        ),
        Question(
            prompt: "Which key assumption is not required for a paper LBO?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Purchase price", isCorrect: false),
                AnswerChoice(text: "Debt and equity mix", isCorrect: false),
                AnswerChoice(text: "Revenue growth of acquirer", isCorrect: true),
                AnswerChoice(text: "Interest rate", isCorrect: false)
            ],
            explanation: "Paper LBO (mental math LBO) needs: entry price/multiple, debt/equity split, interest rate, EBITDA growth, exit multiple, holding period. The acquirer's (PE firm's) revenue growth is irrelevant—focus is on target company."
        ),
        Question(
            prompt: "The internal rate of return (IRR) measures:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Annualized return on invested equity", isCorrect: true),
                AnswerChoice(text: "Simple profit margin", isCorrect: false),
                AnswerChoice(text: "Return to all investors", isCorrect: false),
                AnswerChoice(text: "Exit multiple growth only", isCorrect: false)
            ],
            explanation: "IRR = discount rate where NPV of equity investment = 0. It's the annualized, time-adjusted return to the PE firm's equity investors. Standard metric for PE performance."
        ),
        Question(
            prompt: "In a simple LBO model, free cash flow is used primarily to:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Pay dividends", isCorrect: false),
                AnswerChoice(text: "Fund M&A", isCorrect: false),
                AnswerChoice(text: "Issue stock", isCorrect: false),
                AnswerChoice(text: "Repay debt", isCorrect: true)
            ],
            explanation: "In LBO models, excess cash flow goes to mandatory debt repayment first. This deleveraging increases equity value at exit. Dividends and M&A are optional; debt paydown is the priority."
        ),
        Question(
            prompt: "What is the usual LBO holding period?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "1–2 years", isCorrect: false),
                AnswerChoice(text: "3–7 years", isCorrect: true),
                AnswerChoice(text: "10–15 years", isCorrect: false),
                AnswerChoice(text: "Indefinite", isCorrect: false)
            ],
            explanation: "Typical PE holding period is 3-7 years. Long enough to implement operational improvements and grow EBITDA, short enough to provide timely returns to LP investors. 5 years is most common for modeling."
        ),
        Question(
            prompt: "If a PE firm invests $500 and exits with $1,500 after 5 years, the MoM multiple is:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "2.0×", isCorrect: false),
                AnswerChoice(text: "2.5×", isCorrect: false),
                AnswerChoice(text: "3.0×", isCorrect: true),
                AnswerChoice(text: "3.5×", isCorrect: false)
            ],
            explanation: "Money-on-Money (MoM) = Exit Proceeds / Equity Invested = $1,500 / $500 = 3.0×. Simple multiple of invested capital. Doesn't account for time (unlike IRR)."
        ),
        Question(
            prompt: "The IRR corresponding to tripling your money in 5 years is approximately:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "15%", isCorrect: false),
                AnswerChoice(text: "20%", isCorrect: false),
                AnswerChoice(text: "25%", isCorrect: true),
                AnswerChoice(text: "45%", isCorrect: false)
            ],
            explanation: "Rule of thumb: 3× in 5 years ≈ 24-25% IRR. Formula: (1 + IRR)^5 = 3 → IRR = 3^(1/5) - 1 ≈ 0.2457 = 24.6%. Commonly cited benchmark."
        ),
        Question(
            prompt: "\"Sources & Uses\" in an LBO show:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Funding and spending of capital at closing", isCorrect: true),
                AnswerChoice(text: "Annual cash flow breakdown", isCorrect: false),
                AnswerChoice(text: "Tax schedules", isCorrect: false),
                AnswerChoice(text: "Equity dilution", isCorrect: false)
            ],
            explanation: "Sources & Uses table shows how the deal is financed (sources: debt, equity) and where money goes at closing (uses: purchase equity, refinance debt, pay fees). Snapshot of transaction structure."
        ),
        Question(
            prompt: "What happens to IRR if holding period increases but exit multiple and cash flows are unchanged?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases", isCorrect: false),
                AnswerChoice(text: "Decreases", isCorrect: true),
                AnswerChoice(text: "Stays constant", isCorrect: false),
                AnswerChoice(text: "Becomes negative", isCorrect: false)
            ],
            explanation: "IRR is time-sensitive. Same absolute return over longer period = lower annualized return. Example: 3× in 3 years (≈45% IRR) vs. 3× in 5 years (≈25% IRR). Time dilutes IRR."
        ),
        Question(
            prompt: "What's the difference between \"assumed\" and \"refinanced\" debt?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Assumed is kept or replaced; refinanced is repaid at closing", isCorrect: true),
                AnswerChoice(text: "Refinanced debt stays outstanding", isCorrect: false),
                AnswerChoice(text: "Both are identical", isCorrect: false),
                AnswerChoice(text: "Assumed debt is always equity-funded", isCorrect: false)
            ],
            explanation: "Assumed debt = existing debt that stays on the balance sheet (or is replaced with new LBO debt). Refinanced debt = old debt paid off at closing using transaction proceeds. Important for Sources & Uses."
        )
    ]

    static let lboSection3: [Question] = [
        Question(
            prompt: "Which statement about Senior vs. Subordinated Debt is correct?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Senior has higher interest rates", isCorrect: false),
                AnswerChoice(text: "Subordinated is secured by assets", isCorrect: false),
                AnswerChoice(text: "Senior has lower interest rates and priority in repayment", isCorrect: true),
                AnswerChoice(text: "Subordinated must amortize yearly", isCorrect: false)
            ],
            explanation: "Senior debt = secured, first priority in repayment, lower risk → lower interest rate (6-8%). Subordinated debt = junior, unsecured, higher risk → higher rate (10-12%). Seniority determines repayment order."
        ),
        Question(
            prompt: "Which debt type typically has no amortization and fixed coupons?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Term Loan A", isCorrect: false),
                AnswerChoice(text: "Term Loan B", isCorrect: false),
                AnswerChoice(text: "Senior Notes", isCorrect: true),
                AnswerChoice(text: "Revolver", isCorrect: false)
            ],
            explanation: "Senior Notes (bonds) typically have no amortization—bullet repayment at maturity with fixed coupons. Term Loans have amortization (gradual repayment). Revolvers are drawn/repaid as needed."
        ),
        Question(
            prompt: "Why do LBO models often ignore full Purchase Price Allocation (PPA)?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "It has minimal impact on cash-based returns", isCorrect: true),
                AnswerChoice(text: "It changes equity drastically", isCorrect: false),
                AnswerChoice(text: "It affects MoM multiples significantly", isCorrect: false),
                AnswerChoice(text: "It is illegal in LBOs", isCorrect: false)
            ],
            explanation: "PPA affects accounting (goodwill, intangibles) but not cash flows. LBO returns depend on cash generation and debt paydown—not accounting treatment. Simplifying assumption that doesn't materially affect IRR/MoM."
        ),
        Question(
            prompt: "What is the key difference between LBO and M&A models?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "LBO models ignore IRR", isCorrect: false),
                AnswerChoice(text: "LBO models focus on cash flows and debt repayment", isCorrect: true),
                AnswerChoice(text: "M&A models exclude equity", isCorrect: false),
                AnswerChoice(text: "Both are identical", isCorrect: false)
            ],
            explanation: "LBO models are cash-centric: can we generate enough cash to service debt and deliver returns? Track debt schedules, cash sweeps, IRR. M&A models focus on accretion/dilution (EPS impact) and strategic synergies."
        ),
        Question(
            prompt: "If Free Cash Flow increases, all else equal, IRR:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Decreases", isCorrect: false),
                AnswerChoice(text: "Increases", isCorrect: true),
                AnswerChoice(text: "Unchanged", isCorrect: false),
                AnswerChoice(text: "Becomes negative", isCorrect: false)
            ],
            explanation: "Higher FCF → more cash available for debt paydown → lower debt at exit → higher equity value at exit → higher IRR. Cash flow generation is a key return driver in LBOs."
        ),
        Question(
            prompt: "Ideal LBO target companies generally have:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "High cyclicality and minimal assets", isCorrect: false),
                AnswerChoice(text: "Stable cash flow and low CapEx needs", isCorrect: true),
                AnswerChoice(text: "High R&D intensity", isCorrect: false),
                AnswerChoice(text: "Unpredictable earnings", isCorrect: false)
            ],
            explanation: "Ideal LBO targets: predictable cash flows (to service debt), low capex (more cash for debt paydown), strong market position, limited cyclicality. Stable, boring businesses are perfect—they can handle leverage."
        ),
        Question(
            prompt: "Why do PE firms prefer stable industries?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Easier to predict returns and service debt", isCorrect: true),
                AnswerChoice(text: "Allows rapid multiple expansion", isCorrect: false),
                AnswerChoice(text: "Easier to IPO", isCorrect: false),
                AnswerChoice(text: "Ensures organic growth", isCorrect: false)
            ],
            explanation: "Stable industries have predictable cash flows, reducing risk of missing debt payments. PE firms can confidently lever up knowing cash generation is reliable. Cyclical industries are riskier with high leverage."
        ),
        Question(
            prompt: "What is the \"revolver\" in LBO debt structure?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Long-term subordinated loan", isCorrect: false),
                AnswerChoice(text: "Credit line used to cover short-term cash needs", isCorrect: true),
                AnswerChoice(text: "Dividend payment tool", isCorrect: false),
                AnswerChoice(text: "Convertible note", isCorrect: false)
            ],
            explanation: "Revolver = revolving credit facility. Draw when you need working capital, repay when cash comes in. Provides liquidity buffer. Like a corporate credit card—typically undrawn at closing but available."
        ),
        Question(
            prompt: "A 2× MoM return over 5 years roughly equals what IRR?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "10%", isCorrect: false),
                AnswerChoice(text: "15%", isCorrect: true),
                AnswerChoice(text: "20%", isCorrect: false),
                AnswerChoice(text: "25%", isCorrect: false)
            ],
            explanation: "2× in 5 years ≈ 15% IRR. Formula: (1.15)^5 ≈ 2.01. Quick mental math: 2× in 5 years = 14.9% IRR."
        ),
        Question(
            prompt: "If interest expense rises significantly, how does that affect IRR?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "IRR increases", isCorrect: false),
                AnswerChoice(text: "IRR decreases", isCorrect: true),
                AnswerChoice(text: "No impact", isCorrect: false),
                AnswerChoice(text: "Exit multiple rises", isCorrect: false)
            ],
            explanation: "Higher interest expense → less cash available for debt paydown → higher debt balance at exit → lower equity value → lower IRR. Interest costs drag on returns."
        )
    ]

    static let lboSection4: [Question] = [
        Question(
            prompt: "Which of the following most improves IRR in an LBO?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Extending holding period", isCorrect: false),
                AnswerChoice(text: "Using more debt and repaying it quickly", isCorrect: true),
                AnswerChoice(text: "Higher taxes", isCorrect: false),
                AnswerChoice(text: "Declining EBITDA", isCorrect: false)
            ],
            explanation: "High leverage + fast debt paydown = maximum IRR. Less equity invested, rapid deleveraging increases equity value dramatically. \"Debt paydown\" is one of the three key return drivers (along with EBITDA growth and multiple expansion)."
        ),
        Question(
            prompt: "Which factor least affects IRR?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Entry multiple", isCorrect: false),
                AnswerChoice(text: "Exit multiple", isCorrect: false),
                AnswerChoice(text: "Dividend recap timing", isCorrect: false),
                AnswerChoice(text: "Accounting goodwill", isCorrect: true)
            ],
            explanation: "Goodwill is non-cash accounting. LBO returns are cash-based—goodwill doesn't affect cash generation, debt paydown, or exit proceeds. Entry/exit multiples and leverage directly drive IRR."
        ),
        Question(
            prompt: "If the PE firm exits at a lower multiple but repays all debt, what happens?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "IRR necessarily falls", isCorrect: false),
                AnswerChoice(text: "IRR is unaffected", isCorrect: false),
                AnswerChoice(text: "IRR may still be strong if cash flow growth and deleveraging are high", isCorrect: true),
                AnswerChoice(text: "Exit value = entry value", isCorrect: false)
            ],
            explanation: "Multiple compression hurts, but strong EBITDA growth and complete deleveraging can offset it. Equity value = EV - Debt. If debt goes to zero and EBITDA doubles, you can still achieve good returns despite lower exit multiple."
        ),
        Question(
            prompt: "Why might an IPO exit produce a lower IRR than an M&A exit?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "It provides partial liquidity over time", isCorrect: true),
                AnswerChoice(text: "It involves higher taxes", isCorrect: false),
                AnswerChoice(text: "It's risk-free", isCorrect: false),
                AnswerChoice(text: "It doubles cash immediately", isCorrect: false)
            ],
            explanation: "IPO = gradual exit via lockup expiration and secondary offerings over time. M&A = immediate, full liquidity at closing. Same absolute return over longer timeframe (due to IPO process) = lower IRR."
        ),
        Question(
            prompt: "A \"dividend recapitalization\" means:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Issuing new equity to pay dividends", isCorrect: false),
                AnswerChoice(text: "Issuing new debt to pay dividends to the PE sponsor", isCorrect: true),
                AnswerChoice(text: "Reducing dividends to repay debt", isCorrect: false),
                AnswerChoice(text: "Selling part of the company", isCorrect: false)
            ],
            explanation: "Dividend recap = company borrows additional debt to pay a dividend to the PE sponsor. PE firm gets cash out early (partial return of capital) while still owning 100% of equity. Increases leverage."
        ),
        Question(
            prompt: "Which return driver adds value without changing leverage or multiples?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Multiple expansion", isCorrect: false),
                AnswerChoice(text: "EBITDA growth", isCorrect: true),
                AnswerChoice(text: "Deleveraging", isCorrect: false),
                AnswerChoice(text: "Tax shield", isCorrect: false)
            ],
            explanation: "EBITDA growth = operational improvement that increases enterprise value organically. Doesn't depend on financial engineering (leverage) or market sentiment (multiples). Most sustainable return driver—actual business improvement."
        ),
        Question(
            prompt: "A PE firm earns 3× MoM in 3 years. Approximate IRR?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "25%", isCorrect: false),
                AnswerChoice(text: "35%", isCorrect: false),
                AnswerChoice(text: "45%", isCorrect: true),
                AnswerChoice(text: "60%", isCorrect: false)
            ],
            explanation: "3× in 3 years ≈ 44-45% IRR. Formula: (1 + IRR)^3 = 3 → IRR = 3^(1/3) - 1 ≈ 0.4422 = 44.2%."
        ),
        Question(
            prompt: "What is the relationship between IRR and MoM multiple?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "IRR ignores holding period", isCorrect: false),
                AnswerChoice(text: "Shorter holding periods magnify IRR for same MoM", isCorrect: true),
                AnswerChoice(text: "Longer holding periods always increase IRR", isCorrect: false),
                AnswerChoice(text: "They are identical metrics", isCorrect: false)
            ],
            explanation: "IRR is time-adjusted; MoM is not. Same MoM over shorter period = higher IRR. Example: 3× in 3 years (45% IRR) vs. 3× in 5 years (25% IRR). Time is the key difference."
        ),
        Question(
            prompt: "When leverage is excessive, downside risk increases because:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The company becomes less valuable", isCorrect: false),
                AnswerChoice(text: "Equity dilution rises", isCorrect: false),
                AnswerChoice(text: "Interest payments may exceed cash flow", isCorrect: true),
                AnswerChoice(text: "Debt is tax-free", isCorrect: false)
            ],
            explanation: "Overleveraging means fixed interest obligations may exceed cash generation, especially if EBITDA declines. Can't service debt → default, bankruptcy, equity wiped out. Leverage magnifies downside risk."
        ),
        Question(
            prompt: "What drives most of a successful LBO's returns?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Synergies", isCorrect: false),
                AnswerChoice(text: "Multiple expansion", isCorrect: false),
                AnswerChoice(text: "IPO performance", isCorrect: false),
                AnswerChoice(text: "EBITDA growth and debt paydown", isCorrect: true)
            ],
            explanation: "The \"3 sources of returns\" in LBOs: (1) EBITDA growth (operational improvement—most important), (2) Debt paydown (deleveraging), (3) Multiple expansion (least controllable). EBITDA growth + deleveraging drive most value creation."
        )
    ]

    static let valuationLevel1: [Question] = [
        Question(
            prompt: "What does \"Enterprise Value\" represent?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The company's market capitalization", isCorrect: false),
                AnswerChoice(text: "The value of the company's core operations to all investors", isCorrect: true),
                AnswerChoice(text: "The value of equity plus dividends", isCorrect: false),
                AnswerChoice(text: "The total assets on the balance sheet", isCorrect: false)
            ],
            explanation: "Enterprise Value represents the total value of a company's core operating business to all capital providers (both debt and equity holders), excluding non-operating assets like excess cash."
        ),
        Question(
            prompt: "What does \"Equity Value\" represent?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The value to all investors", isCorrect: false),
                AnswerChoice(text: "The value of debt", isCorrect: false),
                AnswerChoice(text: "The value attributable to shareholders", isCorrect: true),
                AnswerChoice(text: "The liquidation value", isCorrect: false)
            ],
            explanation: "Equity Value (Market Capitalization) represents the value belonging specifically to common shareholders—what they would receive after all debt and other obligations are paid."
        ),
        Question(
            prompt: "Which of the following formulas correctly expresses Enterprise Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EV = Equity Value – Debt + Cash", isCorrect: false),
                AnswerChoice(text: "EV = Equity Value + Debt – Cash", isCorrect: true),
                AnswerChoice(text: "EV = Assets – Liabilities", isCorrect: false),
                AnswerChoice(text: "EV = Market Cap + Retained Earnings", isCorrect: false)
            ],
            explanation: "Standard EV formula: EV = Equity Value + Debt - Cash. Add debt (claim on the company) and subtract cash (non-operating asset that reduces net acquisition cost)."
        ),
        Question(
            prompt: "Why do we subtract cash in the Enterprise Value formula?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cash is not an operating asset", isCorrect: true),
                AnswerChoice(text: "Cash increases net debt", isCorrect: false),
                AnswerChoice(text: "Cash always belongs to lenders", isCorrect: false),
                AnswerChoice(text: "Cash is taxed differently", isCorrect: false)
            ],
            explanation: "Cash is subtracted because it's an excess, non-operating asset not needed to generate operating earnings. When acquiring a company, you effectively get the cash back, reducing your net cost."
        ),
        Question(
            prompt: "Which of the following is not a component of Enterprise Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Debt", isCorrect: false),
                AnswerChoice(text: "Preferred Stock", isCorrect: false),
                AnswerChoice(text: "Minority Interest", isCorrect: false),
                AnswerChoice(text: "Accounts Payable", isCorrect: true)
            ],
            explanation: "Accounts Payable is an operating liability, not part of the EV calculation. EV includes Debt, Preferred Stock, and Minority Interest—all non-operational financing sources with claims on the company."
        ),
        Question(
            prompt: "What does the market capitalization of a company represent?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Book value of equity", isCorrect: false),
                AnswerChoice(text: "Current share price × diluted shares outstanding", isCorrect: true),
                AnswerChoice(text: "Total debt minus cash", isCorrect: false),
                AnswerChoice(text: "Operating value", isCorrect: false)
            ],
            explanation: "Market Capitalization = Share Price × Shares Outstanding. It represents the total market value of a company's equity. Use diluted shares for completeness in valuation work."
        ),
        Question(
            prompt: "Which of the following is an example of a \"non-operating asset\"?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Accounts Receivable", isCorrect: false),
                AnswerChoice(text: "Inventory", isCorrect: false),
                AnswerChoice(text: "Cash and Marketable Securities", isCorrect: true),
                AnswerChoice(text: "PP&E", isCorrect: false)
            ],
            explanation: "Cash and marketable securities don't generate operating returns—they're financial assets. A/R, Inventory, and PP&E are all operational assets used in the core business."
        ),
        Question(
            prompt: "Which valuation multiple uses Enterprise Value in the numerator?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "P/E", isCorrect: false),
                AnswerChoice(text: "EV/EBITDA", isCorrect: true),
                AnswerChoice(text: "Price/Book", isCorrect: false),
                AnswerChoice(text: "Dividend Yield", isCorrect: false)
            ],
            explanation: "EV/EBITDA uses Enterprise Value in the numerator, making it capital structure-neutral. It compares enterprise value to operating earnings available to all investors."
        ),
        Question(
            prompt: "Which valuation multiple uses Equity Value in the numerator?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EV/EBITDA", isCorrect: false),
                AnswerChoice(text: "EV/EBIT", isCorrect: false),
                AnswerChoice(text: "P/E", isCorrect: true),
                AnswerChoice(text: "EV/Sales", isCorrect: false)
            ],
            explanation: "P/E = Price (Equity Value) / Earnings (Net Income). Equity value in numerator, earnings to equity holders in denominator. Capital structure-dependent metric."
        ),
        Question(
            prompt: "What does EBITDA approximate?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cash flow available to all investors", isCorrect: true),
                AnswerChoice(text: "Net income to equity holders", isCorrect: false),
                AnswerChoice(text: "Free cash flow to equity", isCorrect: false),
                AnswerChoice(text: "GAAP profit", isCorrect: false)
            ],
            explanation: "EBITDA (Earnings Before Interest, Taxes, Depreciation, Amortization) approximates operating cash flow before financing costs, taxes, and working capital changes—available to both debt and equity holders."
        )
    ]

    static let valuationLevel2: [Question] = [
        Question(
            prompt: "If a company has $200M market cap, $50M debt, and $10M cash, EV = ?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "$160M", isCorrect: false),
                AnswerChoice(text: "$240M", isCorrect: true),
                AnswerChoice(text: "$250M", isCorrect: false),
                AnswerChoice(text: "$190M", isCorrect: false)
            ],
            explanation: "EV = Market Cap + Debt - Cash = $200M + $50M - $10M = $240M."
        ),
        Question(
            prompt: "A company's EV/EBITDA multiple is 8x and EBITDA is $50M. EV = ?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "$400M", isCorrect: true),
                AnswerChoice(text: "$350M", isCorrect: false),
                AnswerChoice(text: "$450M", isCorrect: false),
                AnswerChoice(text: "$600M", isCorrect: false)
            ],
            explanation: "EV = EV/EBITDA × EBITDA = 8 × $50M = $400M."
        ),
        Question(
            prompt: "If EV = $400M and debt = $100M, cash = $20M, then Equity Value = ?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "$320M", isCorrect: true),
                AnswerChoice(text: "$480M", isCorrect: false),
                AnswerChoice(text: "$520M", isCorrect: false),
                AnswerChoice(text: "$380M", isCorrect: false)
            ],
            explanation: "Rearranging EV formula: Equity Value = EV - Debt + Cash = $400M - $100M + $20M = $320M."
        ),
        Question(
            prompt: "Which of the following would decrease Enterprise Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Issue new debt", isCorrect: false),
                AnswerChoice(text: "Repay debt", isCorrect: true),
                AnswerChoice(text: "Acquire another company", isCorrect: false),
                AnswerChoice(text: "Increase EBITDA", isCorrect: false)
            ],
            explanation: "Repaying debt decreases EV because debt is a component of EV. EV = Equity + Debt - Cash, so reducing debt reduces EV (all else equal)."
        ),
        Question(
            prompt: "If a company issues stock and keeps the cash, what happens to EV?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EV increases", isCorrect: false),
                AnswerChoice(text: "EV decreases", isCorrect: false),
                AnswerChoice(text: "EV stays the same", isCorrect: true),
                AnswerChoice(text: "EV doubles", isCorrect: false)
            ],
            explanation: "Issuing stock increases Equity Value by X and increases Cash by X. Since EV = Equity + Debt - Cash, the equity increase is offset by the cash increase, leaving EV unchanged."
        ),
        Question(
            prompt: "If a company uses $100M in cash to repay debt, what happens to EV?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "No change", isCorrect: true),
                AnswerChoice(text: "Increases $100M", isCorrect: false),
                AnswerChoice(text: "Decreases $100M", isCorrect: false),
                AnswerChoice(text: "Increases $50M", isCorrect: false)
            ],
            explanation: "Cash ↓$100M and Debt ↓$100M. In the EV formula (EV = Equity + Debt - Cash), both components change by the same amount in opposite directions, so EV is unchanged."
        ),
        Question(
            prompt: "Which of the following is added to Equity Value to calculate EV?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cash", isCorrect: false),
                AnswerChoice(text: "Deferred Tax Asset", isCorrect: false),
                AnswerChoice(text: "Debt", isCorrect: true),
                AnswerChoice(text: "Treasury Stock", isCorrect: false)
            ],
            explanation: "EV = Equity Value + Debt - Cash. Debt is added to equity value because it represents another claim on the company's assets and cash flows."
        ),
        Question(
            prompt: "Why is minority interest added to Enterprise Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To reflect control premium", isCorrect: false),
                AnswerChoice(text: "Because consolidated EBITDA includes minority-owned subsidiaries", isCorrect: true),
                AnswerChoice(text: "To adjust for tax differences", isCorrect: false),
                AnswerChoice(text: "To exclude non-controlling shareholders", isCorrect: false)
            ],
            explanation: "When you consolidate a majority-owned subsidiary, you include 100% of its EBITDA but only own part of it. Minority interest represents the portion owned by others, so it's added to EV to reflect the full enterprise value."
        ),
        Question(
            prompt: "If a company's EV/EBITDA multiple rises but EBITDA stays constant, what must have changed?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Market Cap increased", isCorrect: true),
                AnswerChoice(text: "Debt decreased", isCorrect: false),
                AnswerChoice(text: "Cash increased", isCorrect: false),
                AnswerChoice(text: "All of the above", isCorrect: false)
            ],
            explanation: "If EV/EBITDA rises and EBITDA is constant, then EV must have increased. Since EV = Equity + Debt - Cash, the most likely driver is Market Cap (Equity Value) increasing."
        ),
        Question(
            prompt: "A company has EV = $500M and EBITDA = $50M. What is its EV/EBITDA?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "5×", isCorrect: false),
                AnswerChoice(text: "8×", isCorrect: false),
                AnswerChoice(text: "10×", isCorrect: true),
                AnswerChoice(text: "12×", isCorrect: false)
            ],
            explanation: "EV/EBITDA = $500M / $50M = 10×."
        )
    ]

    static let valuationLevel3: [Question] = [
        Question(
            prompt: "Which of the following multiples best compares companies with different tax rates?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "P/E", isCorrect: false),
                AnswerChoice(text: "EV/EBITDA", isCorrect: true),
                AnswerChoice(text: "Price/Book", isCorrect: false),
                AnswerChoice(text: "Dividend Yield", isCorrect: false)
            ],
            explanation: "EV/EBITDA is pre-tax (EBITDA is before taxes), so it's not affected by different tax rates. P/E uses Net Income which is post-tax, making comparisons difficult across different tax jurisdictions."
        ),
        Question(
            prompt: "Why is P/E considered a \"post-debt\" multiple?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "It uses Enterprise Value", isCorrect: false),
                AnswerChoice(text: "It uses pre-interest income", isCorrect: false),
                AnswerChoice(text: "It's based on Net Income, after interest expense", isCorrect: true),
                AnswerChoice(text: "It ignores capital structure", isCorrect: false)
            ],
            explanation: "P/E is based on Net Income, which is calculated after interest expense has been deducted. Therefore, it's affected by capital structure (amount of debt) and is a \"post-debt\" metric."
        ),
        Question(
            prompt: "Which of the following items would you adjust out when normalizing EBITDA?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Recurring rent expense", isCorrect: false),
                AnswerChoice(text: "One-time restructuring charge", isCorrect: true),
                AnswerChoice(text: "Payroll", isCorrect: false),
                AnswerChoice(text: "Cost of goods sold", isCorrect: false)
            ],
            explanation: "When normalizing EBITDA, remove non-recurring, one-time items like restructuring charges to show run-rate operating performance. Keep recurring operating expenses like rent, payroll, and COGS."
        ),
        Question(
            prompt: "Which valuation method gives the highest value in strong markets?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "DCF", isCorrect: false),
                AnswerChoice(text: "Precedent Transactions", isCorrect: true),
                AnswerChoice(text: "Public Comps", isCorrect: false),
                AnswerChoice(text: "Book Value", isCorrect: false)
            ],
            explanation: "Precedent Transactions typically yield the highest values because they include control premiums and often occur during favorable market conditions when buyers are aggressive. DCF is theoretical; public comps reflect current market."
        ),
        Question(
            prompt: "Which is the most theoretically correct valuation method?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "DCF", isCorrect: true),
                AnswerChoice(text: "Public Comps", isCorrect: false),
                AnswerChoice(text: "Precedent Transactions", isCorrect: false),
                AnswerChoice(text: "Book Value", isCorrect: false)
            ],
            explanation: "DCF is most theoretically sound because it values based on intrinsic cash flow generation ability, not market sentiment. It's forward-looking and captures the fundamental value drivers."
        ),
        Question(
            prompt: "If a company's EV/EBITDA is lower than peers, it may indicate:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Overvaluation", isCorrect: false),
                AnswerChoice(text: "Undervaluation", isCorrect: true),
                AnswerChoice(text: "Higher growth", isCorrect: false),
                AnswerChoice(text: "Lower margins", isCorrect: false)
            ],
            explanation: "Lower EV/EBITDA than peers suggests the company is cheaper relative to its earnings—potential undervaluation. However, could also indicate lower growth prospects or higher risk. Requires further analysis."
        ),
        Question(
            prompt: "Which multiple is most relevant for unprofitable companies?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "P/E", isCorrect: false),
                AnswerChoice(text: "EV/EBITDA", isCorrect: false),
                AnswerChoice(text: "EV/Sales", isCorrect: true),
                AnswerChoice(text: "P/B", isCorrect: false)
            ],
            explanation: "Unprofitable companies have negative or no earnings, making P/E and EV/EBITDA unusable. EV/Sales works because revenue exists even without profitability. Also called EV/Revenue."
        ),
        Question(
            prompt: "Which is most affected by differences in capital structure?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EV/EBITDA", isCorrect: false),
                AnswerChoice(text: "EV/EBIT", isCorrect: false),
                AnswerChoice(text: "P/E", isCorrect: true),
                AnswerChoice(text: "EV/Sales", isCorrect: false)
            ],
            explanation: "P/E uses Net Income (post-interest), so it's heavily affected by leverage. High debt → high interest expense → lower Net Income → different P/E. EV multiples are capital structure-neutral."
        ),
        Question(
            prompt: "Which metric reflects operating profitability before non-cash charges?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EBITDA", isCorrect: true),
                AnswerChoice(text: "EBIT", isCorrect: false),
                AnswerChoice(text: "Net Income", isCorrect: false),
                AnswerChoice(text: "Free Cash Flow", isCorrect: false)
            ],
            explanation: "EBITDA = Earnings Before Interest, Taxes, Depreciation, Amortization. It shows operating profitability before non-cash charges (D&A) and financing/tax effects."
        ),
        Question(
            prompt: "If two firms have identical EV/EBITDA but different growth rates, which likely trades at a higher P/E?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The higher-growth firm", isCorrect: true),
                AnswerChoice(text: "The lower-growth firm", isCorrect: false),
                AnswerChoice(text: "Both equal", isCorrect: false),
                AnswerChoice(text: "Not enough data", isCorrect: false)
            ],
            explanation: "Higher growth → higher future earnings → higher equity value → higher P/E. Even with same EV/EBITDA, the higher-growth firm commands a premium P/E because investors value earnings growth."
        )
    ]

    static let valuationLevel4: [Question] = [
        Question(
            prompt: "A firm's EV = $600M, Debt = $200M, Cash = $50M, Minority Interest = $25M. What is Equity Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "$375M", isCorrect: false),
                AnswerChoice(text: "$400M", isCorrect: false),
                AnswerChoice(text: "$325M", isCorrect: false),
                AnswerChoice(text: "$425M", isCorrect: true)
            ],
            explanation: "Equity Value = EV - Debt + Cash - Minority Interest = $600M - $200M + $50M - $25M = $425M."
        ),
        Question(
            prompt: "A company's market cap is $500M with $100M debt and $50M cash. It acquires a $100M target with 50% cash, 50% debt. New EV = ?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "$600M", isCorrect: false),
                AnswerChoice(text: "$650M", isCorrect: false),
                AnswerChoice(text: "$700M", isCorrect: true),
                AnswerChoice(text: "$750M", isCorrect: false)
            ],
            explanation: "Initial EV = $500M + $100M - $50M = $550M. Add target EV: +$100M. Use $50M cash (reduces cash by $50M, increases EV by $50M net). Add $50M new debt (+$50M to EV). New EV = $550M + $100M + $50M = $700M."
        ),
        Question(
            prompt: "If you increase a company's cash balance while keeping everything else constant, what happens to P/E?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases", isCorrect: false),
                AnswerChoice(text: "Decreases", isCorrect: false),
                AnswerChoice(text: "No change", isCorrect: true),
                AnswerChoice(text: "Depends on dividends", isCorrect: false)
            ],
            explanation: "P/E = Price / EPS. If cash increases without operational change, neither Net Income nor share price should fundamentally change (cash is non-operating). P/E theoretically remains unchanged. Note: In practice, market may revalue the company."
        ),
        Question(
            prompt: "In a DCF, what does WACC represent?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Weighted average cost of equity and debt for all investors", isCorrect: true),
                AnswerChoice(text: "Required return to equity holders", isCorrect: false),
                AnswerChoice(text: "Cost of debt only", isCorrect: false),
                AnswerChoice(text: "Tax rate × cost of capital", isCorrect: false)
            ],
            explanation: "WACC (Weighted Average Cost of Capital) = (E/V) × Cost of Equity + (D/V) × After-tax Cost of Debt. It's the blended cost of capital representing all investors' required returns."
        ),
        Question(
            prompt: "If WACC decreases while FCF stays constant, what happens to Enterprise Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases", isCorrect: true),
                AnswerChoice(text: "Decreases", isCorrect: false),
                AnswerChoice(text: "No change", isCorrect: false),
                AnswerChoice(text: "Becomes negative", isCorrect: false)
            ],
            explanation: "Lower discount rate (WACC) increases the present value of future cash flows. DCF formula: EV = Σ(FCF / (1+WACC)^t). Lower WACC in denominator → higher EV."
        ),
        Question(
            prompt: "Which valuation method would you trust least in a cyclical industry?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "DCF", isCorrect: true),
                AnswerChoice(text: "Public Comps", isCorrect: false),
                AnswerChoice(text: "Precedent Transactions", isCorrect: false),
                AnswerChoice(text: "EV/Sales", isCorrect: false)
            ],
            explanation: "DCF requires long-term cash flow projections, which are highly unreliable in cyclical industries where earnings swing dramatically. Hard to forecast normalized performance. Comps and precedents provide market-based reality checks."
        ),
        Question(
            prompt: "If EV/EBITDA is 10× and the firm's Net Debt is $100M, what's implied P/E if NI = $30M and EBITDA = $50M?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "13.3×", isCorrect: true),
                AnswerChoice(text: "10.5×", isCorrect: false),
                AnswerChoice(text: "8.9×", isCorrect: false),
                AnswerChoice(text: "6.3×", isCorrect: false)
            ],
            explanation: "EV = 10 × $50M = $500M. Equity Value = EV - Net Debt = $500M - $100M = $400M. P/E = $400M / $30M = 13.33× ≈ 13.3×."
        ),
        Question(
            prompt: "When would EV ≈ Equity Value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "When the company has no debt and no cash", isCorrect: true),
                AnswerChoice(text: "When the company is unprofitable", isCorrect: false),
                AnswerChoice(text: "When its EBITDA = Net Income", isCorrect: false),
                AnswerChoice(text: "When WACC = ROIC", isCorrect: false)
            ],
            explanation: "EV = Equity Value + Debt - Cash. If Debt = 0 and Cash = 0, then EV = Equity Value. This occurs when a company is all-equity financed with no excess cash."
        ),
        Question(
            prompt: "Which is a sign of overleveraging in valuation context?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EV/EBITDA > P/E", isCorrect: true),
                AnswerChoice(text: "EV/EBITDA < P/E", isCorrect: false),
                AnswerChoice(text: "P/E increasing faster than EV/EBITDA", isCorrect: false),
                AnswerChoice(text: "EV decreases when debt rises", isCorrect: false)
            ],
            explanation: "When EV/EBITDA > P/E, it suggests high debt burden. EV includes debt, making the EV multiple higher. This indicates significant leverage that's weighing on equity value and P/E."
        ),
        Question(
            prompt: "A company has Net Income $60M, EBITDA $100M, Debt $200M, Cash $20M. P/E = 12×. What is EV/EBITDA?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "10×", isCorrect: false),
                AnswerChoice(text: "11×", isCorrect: false),
                AnswerChoice(text: "12×", isCorrect: false),
                AnswerChoice(text: "9×", isCorrect: true)
            ],
            explanation: "Market Cap = P/E × NI = 12 × $60M = $720M. EV = $720M + $200M - $20M = $900M. EV/EBITDA = $900M / $100M = 9×."
        )
    ]

    static let threeStatements: [Question] = [
        Question(
            prompt: "Increasing depreciation has what immediate effect on cash flow?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases cash flow", isCorrect: true),
                AnswerChoice(text: "Decreases cash flow", isCorrect: false),
                AnswerChoice(text: "No effect", isCorrect: false)
            ],
            explanation: "Non-cash expense reduces taxable income, lowering taxes paid; CFO increases."
        )
    ]

    static let maSection1: [Question] = [
        Question(
            prompt: "What is the primary goal of an acquisition?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Create value for shareholders through synergies", isCorrect: true),
                AnswerChoice(text: "Diversify management", isCorrect: false),
                AnswerChoice(text: "Increase EPS in the short term", isCorrect: false),
                AnswerChoice(text: "Reduce competition only", isCorrect: false)
            ],
            explanation: "Strategic M&A aims to create value by combining companies to achieve synergies (cost savings, revenue growth) that exceed the acquisition premium paid. Shareholder value creation is the ultimate goal."
        ),
        Question(
            prompt: "In an M&A deal, the buyer is also known as the:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Acquirer", isCorrect: true),
                AnswerChoice(text: "Target", isCorrect: false),
                AnswerChoice(text: "Seller", isCorrect: false),
                AnswerChoice(text: "Investor", isCorrect: false)
            ],
            explanation: "Acquirer = buyer = bidder. The company initiating and paying for the acquisition. The company making the offer."
        ),
        Question(
            prompt: "The target company refers to:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The company initiating the acquisition", isCorrect: false),
                AnswerChoice(text: "The company financing the deal", isCorrect: false),
                AnswerChoice(text: "The company being acquired", isCorrect: true),
                AnswerChoice(text: "The advisor", isCorrect: false)
            ],
            explanation: "Target = seller = the company being purchased. The company receiving the acquisition offer."
        ),
        Question(
            prompt: "A merger of equals is best described as:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "A hostile takeover", isCorrect: false),
                AnswerChoice(text: "A spin-off transaction", isCorrect: false),
                AnswerChoice(text: "A stock repurchase", isCorrect: false),
                AnswerChoice(text: "A merger where both firms have similar size and valuation", isCorrect: true)
            ],
            explanation: "Merger of equals = two similarly-sized companies combining, often with shared governance and no clear \"acquirer.\" Both managements and boards typically stay involved. Rare in practice."
        ),
        Question(
            prompt: "What is a \"friendly\" deal?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "When both companies agree to merge", isCorrect: true),
                AnswerChoice(text: "When the acquirer launches a tender offer", isCorrect: false),
                AnswerChoice(text: "When shareholders resist", isCorrect: false),
                AnswerChoice(text: "When the deal is financed with debt", isCorrect: false)
            ],
            explanation: "Friendly deal = management and boards of both companies support the transaction. Negotiations are collaborative, terms are mutually agreed upon. Contrast with hostile takeover."
        ),
        Question(
            prompt: "What's a \"hostile takeover\"?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "When management of the target supports the deal", isCorrect: false),
                AnswerChoice(text: "When acquirer uses only equity", isCorrect: false),
                AnswerChoice(text: "When antitrust issues arise", isCorrect: false),
                AnswerChoice(text: "When acquirer bypasses management and goes directly to shareholders", isCorrect: true)
            ],
            explanation: "Hostile takeover = acquirer makes unsolicited offer directly to target shareholders, bypassing resistant management. May use tender offer or proxy fight to gain control despite management opposition."
        ),
        Question(
            prompt: "What is a \"strategic buyer\"?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "A private equity firm", isCorrect: false),
                AnswerChoice(text: "A financial investor", isCorrect: false),
                AnswerChoice(text: "A company acquiring another for operational synergies", isCorrect: true),
                AnswerChoice(text: "A government body", isCorrect: false)
            ],
            explanation: "Strategic buyer = operating company seeking synergies (cost savings, scale, technology, customers). Motivated by operational integration and strategic fit, not just financial returns."
        ),
        Question(
            prompt: "What is a \"financial buyer\"?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "A company seeking long-term integration", isCorrect: false),
                AnswerChoice(text: "A hostile acquirer", isCorrect: false),
                AnswerChoice(text: "A PE firm or fund seeking returns", isCorrect: true),
                AnswerChoice(text: "A joint venture partner", isCorrect: false)
            ],
            explanation: "Financial buyer = PE firm buying for financial returns through leverage and operational improvements, not strategic synergies. Exit-focused (3-7 years), not looking for strategic integration."
        ),
        Question(
            prompt: "Which of the following is not a typical motivation for M&A?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Achieving synergies", isCorrect: false),
                AnswerChoice(text: "Market share expansion", isCorrect: false),
                AnswerChoice(text: "Tax benefits", isCorrect: false),
                AnswerChoice(text: "Reducing the number of employees for PR", isCorrect: true)
            ],
            explanation: "Valid M&A motivations: synergies, market share, diversification, tax benefits (NOLs), eliminating competition, acquiring technology/talent. PR-driven layoffs alone is not a strategic rationale."
        ),
        Question(
            prompt: "The \"purchase consideration\" refers to:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "The advisor's fee", isCorrect: false),
                AnswerChoice(text: "The target's total assets", isCorrect: false),
                AnswerChoice(text: "The price paid to acquire the target", isCorrect: true),
                AnswerChoice(text: "The discount rate", isCorrect: false)
            ],
            explanation: "Purchase consideration = total amount paid (cash, stock, or combination) to acquire target shareholders' equity. The \"price tag\" of the deal."
        )
    ]

    static let maSection2: [Question] = [
        Question(
            prompt: "Which of the following is not a payment method in M&A?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cash", isCorrect: false),
                AnswerChoice(text: "Stock", isCorrect: false),
                AnswerChoice(text: "Debt", isCorrect: false),
                AnswerChoice(text: "Warrants", isCorrect: true)
            ],
            explanation: "Common payment methods: cash, stock (acquirer shares), or mix of both. May assume/refinance target's debt. Warrants are not standard M&A consideration—they're equity derivatives used in other contexts."
        ),
        Question(
            prompt: "Why would an acquirer prefer to pay with stock instead of cash?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To avoid issuing shares", isCorrect: false),
                AnswerChoice(text: "To avoid synergies", isCorrect: false),
                AnswerChoice(text: "Because stock is always cheaper", isCorrect: false),
                AnswerChoice(text: "To preserve liquidity and reduce leverage", isCorrect: true)
            ],
            explanation: "Stock deal preserves cash on balance sheet, avoids taking on debt, and maintains financial flexibility. Downside: dilutes existing shareholders. Often used when acquirer stock is perceived as overvalued."
        ),
        Question(
            prompt: "In an all-cash deal, the seller's shareholders receive:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Stock in the buyer", isCorrect: false),
                AnswerChoice(text: "Debt instruments", isCorrect: false),
                AnswerChoice(text: "Equity options", isCorrect: false),
                AnswerChoice(text: "Cash at closing", isCorrect: true)
            ],
            explanation: "All-cash deal = target shareholders receive cash for their shares at closing. Clean exit, immediate liquidity, no ongoing ownership in combined company."
        ),
        Question(
            prompt: "What does \"Exchange Ratio\" represent in a stock-for-stock deal?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Number of target shares issued", isCorrect: false),
                AnswerChoice(text: "Shares of buyer given per target share", isCorrect: true),
                AnswerChoice(text: "Price-to-earnings ratio", isCorrect: false),
                AnswerChoice(text: "Dividends paid to target", isCorrect: false)
            ],
            explanation: "Exchange Ratio = number of acquirer shares given for each target share. Example: 0.5 exchange ratio means target shareholders get 0.5 acquirer shares for every 1 target share they own."
        ),
        Question(
            prompt: "If the acquirer pays a premium, what does that mean?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Paying less than market price", isCorrect: false),
                AnswerChoice(text: "Paying more than target's unaffected share price", isCorrect: true),
                AnswerChoice(text: "Paying face value", isCorrect: false),
                AnswerChoice(text: "Paying only for tangible assets", isCorrect: false)
            ],
            explanation: "Acquisition premium = % above target's pre-announcement stock price (unaffected price). Buyers pay premium for control and expected synergies. Typical premiums: 20-40% in strategic M&A."
        ),
        Question(
            prompt: "Why do buyers pay acquisition premiums?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "To gain control and access synergies", isCorrect: true),
                AnswerChoice(text: "Because regulation requires it", isCorrect: false),
                AnswerChoice(text: "To inflate accounting goodwill", isCorrect: false),
                AnswerChoice(text: "To increase liabilities", isCorrect: false)
            ],
            explanation: "Premiums compensate target shareholders for giving up control and future upside. Buyers pay premium because they expect synergies (cost savings, revenue growth) to justify the higher price."
        ),
        Question(
            prompt: "What is \"goodwill\" in M&A accounting?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Excess of purchase price over fair value of net assets", isCorrect: true),
                AnswerChoice(text: "Cash flow from operations", isCorrect: false),
                AnswerChoice(text: "Amortized expense", isCorrect: false),
                AnswerChoice(text: "Deferred tax benefit", isCorrect: false)
            ],
            explanation: "Goodwill = Purchase Price - Fair Value of Net Identifiable Assets. Represents intangible value: brand, customer relationships, assembled workforce, expected synergies. Goes on acquirer's balance sheet."
        ),
        Question(
            prompt: "When is an acquisition immediately accretive?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "When deal increases book value", isCorrect: false),
                AnswerChoice(text: "When debt decreases", isCorrect: false),
                AnswerChoice(text: "When interest expense rises", isCorrect: false),
                AnswerChoice(text: "When EPS of combined company increases", isCorrect: true)
            ],
            explanation: "Accretive deal = Pro forma EPS (combined company) > Acquirer's standalone EPS. EPS increases immediately post-transaction. Doesn't necessarily mean value creation—just accounting accretion."
        ),
        Question(
            prompt: "Which statement about accretion/dilution is true?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Dilution always means a bad deal", isCorrect: false),
                AnswerChoice(text: "Accretion always means a good deal", isCorrect: false),
                AnswerChoice(text: "Accretion/dilution depends on deal structure and synergies", isCorrect: true),
                AnswerChoice(text: "It's irrelevant to valuation", isCorrect: false)
            ],
            explanation: "Accretion/dilution is an accounting metric, not a value metric. Can be accretive but destroy value (overpaid). Can be dilutive but create value (strategic acquisition with long-term benefits). Context and synergies matter."
        ),
        Question(
            prompt: "Which item generally causes EPS dilution?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Paying with undervalued stock", isCorrect: false),
                AnswerChoice(text: "Paying with overvalued stock", isCorrect: true),
                AnswerChoice(text: "Paying with cash", isCorrect: false),
                AnswerChoice(text: "Using debt with low interest", isCorrect: false)
            ],
            explanation: "Using overvalued stock means issuing many shares to buy target (paying expensive currency). Denominator (share count) increases more than numerator (earnings), causing EPS dilution. Using undervalued stock would be accretive."
        )
    ]

    static let maSection3: [Question] = [
        Question(
            prompt: "In a 100% stock deal, accretion/dilution primarily depends on:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Relative P/E ratios of buyer and seller", isCorrect: true),
                AnswerChoice(text: "Buyer's debt level", isCorrect: false),
                AnswerChoice(text: "Seller's revenue growth", isCorrect: false),
                AnswerChoice(text: "Cash balance", isCorrect: false)
            ],
            explanation: "In stock deals, compare P/E ratios. If Buyer P/E > Target P/E, typically accretive (buying cheaper earnings with expensive stock). If Buyer P/E < Target P/E, typically dilutive (buying expensive earnings with cheap stock). P/E ratio differential drives accretion/dilution."
        ),
        Question(
            prompt: "If Buyer's P/E = 20× and Seller's P/E = 10×, a 100% stock deal is likely:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Accretive", isCorrect: true),
                AnswerChoice(text: "Dilutive", isCorrect: false),
                AnswerChoice(text: "Neutral", isCorrect: false),
                AnswerChoice(text: "Impossible to tell", isCorrect: false)
            ],
            explanation: "Buyer P/E (20×) > Target P/E (10×) → Buyer is acquiring cheaper earnings. Issuing relatively expensive stock (high P/E) to buy relatively cheap earnings (low P/E) → Accretive. Must still consider premium, synergies, and share count math."
        ),
        Question(
            prompt: "If Buyer's P/E = 10× and Seller's P/E = 20×, the deal is likely:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Accretive", isCorrect: false),
                AnswerChoice(text: "Dilutive", isCorrect: true),
                AnswerChoice(text: "Neutral", isCorrect: false),
                AnswerChoice(text: "None of the above", isCorrect: false)
            ],
            explanation: "Buyer P/E (10×) < Target P/E (20×) → Buyer is acquiring expensive earnings. Using relatively cheap stock (low P/E) to buy relatively expensive earnings (high P/E) → Dilutive. Unfavorable currency to target exchange."
        ),
        Question(
            prompt: "Why does higher debt financing increase EPS accretion potential?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Debt is cheaper than equity", isCorrect: true),
                AnswerChoice(text: "Debt is non-taxable", isCorrect: false),
                AnswerChoice(text: "It reduces goodwill", isCorrect: false),
                AnswerChoice(text: "It boosts market capitalization", isCorrect: false)
            ],
            explanation: "Debt has lower after-tax cost than equity (interest is tax-deductible). Using debt avoids share dilution and provides cheaper financing → higher accretion potential. Trade-off: increases leverage and financial risk."
        ),
        Question(
            prompt: "Which synergy directly affects the Income Statement?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Revenue synergy", isCorrect: false),
                AnswerChoice(text: "Cost synergy", isCorrect: true),
                AnswerChoice(text: "Working capital synergy", isCorrect: false),
                AnswerChoice(text: "Tax synergy", isCorrect: false)
            ],
            explanation: "Cost synergies (eliminating redundancies, economies of scale) directly reduce expenses on the Income Statement → increase EBITDA and Net Income. Revenue synergies also affect IS (increase top line). Working capital affects Balance Sheet/Cash Flow."
        ),
        Question(
            prompt: "Which synergy type is usually more reliable?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Revenue synergies", isCorrect: false),
                AnswerChoice(text: "Cost synergies", isCorrect: true),
                AnswerChoice(text: "Tax synergies", isCorrect: false),
                AnswerChoice(text: "Market synergies", isCorrect: false)
            ],
            explanation: "Cost synergies are more predictable and controllable (e.g., eliminate duplicate functions, combine facilities). Revenue synergies depend on customer behavior, market dynamics, competitive response—harder to guarantee and often overestimated."
        ),
        Question(
            prompt: "Which metric best captures synergy value creation?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increase in EBITDA", isCorrect: true),
                AnswerChoice(text: "Decrease in CapEx", isCorrect: false),
                AnswerChoice(text: "Change in equity value", isCorrect: false),
                AnswerChoice(text: "Dividend payout", isCorrect: false)
            ],
            explanation: "Synergies manifest as higher combined EBITDA (revenue synergies increase top line, cost synergies reduce expenses). EBITDA improvement directly translates to higher enterprise value. Most common metric for quantifying synergy realization."
        ),
        Question(
            prompt: "What is the main driver of goodwill creation?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Synergies", isCorrect: false),
                AnswerChoice(text: "Purchase price premium", isCorrect: true),
                AnswerChoice(text: "Working capital", isCorrect: false),
                AnswerChoice(text: "Leverage ratio", isCorrect: false)
            ],
            explanation: "Goodwill = Purchase Price - Fair Value of Net Assets. Larger premium paid → more goodwill created. Premium reflects expected synergies and control value, but goodwill itself is driven by how much over fair value you pay."
        ),
        Question(
            prompt: "Which item affects both the Income Statement and Cash Flow Statement in a deal model?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Amortization of intangible assets", isCorrect: true),
                AnswerChoice(text: "Deferred tax asset", isCorrect: false),
                AnswerChoice(text: "Retained earnings", isCorrect: false),
                AnswerChoice(text: "Minority interest", isCorrect: false)
            ],
            explanation: "Intangible asset amortization (from purchase accounting) is a non-cash expense on Income Statement (reduces NI) and added back in Cash Flow Statement (like depreciation). Affects both statements but not actual cash."
        ),
        Question(
            prompt: "The amortization of intangibles created in purchase accounting generally:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases Net Income", isCorrect: false),
                AnswerChoice(text: "Decreases Net Income", isCorrect: true),
                AnswerChoice(text: "No effect", isCorrect: false),
                AnswerChoice(text: "Increases EBITDA", isCorrect: false)
            ],
            explanation: "Amortization of acquired intangibles (customer relationships, technology, trademarks) is an expense that reduces Net Income post-acquisition. It's non-cash but creates an accounting drag on earnings. Doesn't affect EBITDA."
        )
    ]

    static let maSection4: [Question] = [
        Question(
            prompt: "Why can a deal be accretive but destroy shareholder value?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Synergies overstated or premium too high", isCorrect: true),
                AnswerChoice(text: "EPS always misleads", isCorrect: false),
                AnswerChoice(text: "No debt involved", isCorrect: false),
                AnswerChoice(text: "P/E ratios align", isCorrect: false)
            ],
            explanation: "Accretion is an accounting metric, not value metric. Can be accretive if: (1) synergies overstated and don't materialize, (2) premium paid exceeds synergy value, (3) opportunity cost ignored, (4) integration fails. EPS ↑ doesn't guarantee value creation."
        ),
        Question(
            prompt: "What's the key tradeoff in M&A financing?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cash reduces flexibility but avoids dilution", isCorrect: true),
                AnswerChoice(text: "Stock is always cheaper", isCorrect: false),
                AnswerChoice(text: "Debt is always safer", isCorrect: false),
                AnswerChoice(text: "Premiums eliminate risk", isCorrect: false)
            ],
            explanation: "Cash: depletes balance sheet, limits flexibility, but no shareholder dilution. Stock: preserves cash, maintains flexibility, but dilutes existing shareholders. Debt: middle ground but increases leverage. No perfect answer—depends on circumstances."
        ),
        Question(
            prompt: "A deal financed 50% debt, 50% stock will be most sensitive to:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Cost of debt and relative P/Es", isCorrect: true),
                AnswerChoice(text: "Dividend payout", isCorrect: false),
                AnswerChoice(text: "Working capital", isCorrect: false),
                AnswerChoice(text: "Tax shield", isCorrect: false)
            ],
            explanation: "Mixed financing sensitivity: debt component affected by interest rates (cost of debt impacts interest expense and accretion). Stock component affected by P/E differentials (drives stock-for-stock accretion/dilution). Both are key drivers."
        ),
        Question(
            prompt: "Why might a buyer use debt instead of stock?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Debt is cheaper and signals confidence", isCorrect: true),
                AnswerChoice(text: "Stock is easier to raise", isCorrect: false),
                AnswerChoice(text: "Debt is tax-free", isCorrect: false),
                AnswerChoice(text: "Stock reduces IRR", isCorrect: false)
            ],
            explanation: "Debt advantages: (1) cheaper than equity (tax-deductible interest), (2) no dilution, (3) signals management confidence in cash flow generation to service debt. Debt financing is a positive signal about expected synergies and integration success."
        ),
        Question(
            prompt: "What happens if the target has large NOLs (Net Operating Losses)?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases combined company's tax shield", isCorrect: true),
                AnswerChoice(text: "Reduces goodwill", isCorrect: false),
                AnswerChoice(text: "Causes dilution", isCorrect: false),
                AnswerChoice(text: "Increases amortization", isCorrect: false)
            ],
            explanation: "NOLs (Net Operating Losses) can offset future taxable income of combined company, reducing cash taxes—valuable tax asset. Subject to Section 382 limitations on usage post-acquisition, but can provide significant value if usable."
        ),
        Question(
            prompt: "Which method of valuation adjustment is most important in an M&A deal model?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Purchase price allocation (PPA)", isCorrect: true),
                AnswerChoice(text: "Dividend recapitalization", isCorrect: false),
                AnswerChoice(text: "Levered DCF", isCorrect: false),
                AnswerChoice(text: "Comparable multiples", isCorrect: false)
            ],
            explanation: "PPA determines: goodwill, identifiable intangibles, deferred taxes, step-ups—all critical for pro forma financials. Drives amortization expense, tax effects, balance sheet presentation. Essential for accurate accretion/dilution analysis."
        ),
        Question(
            prompt: "If an acquirer pays entirely with debt and interest rates double, what's the likely outcome?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EPS accretion increases", isCorrect: false),
                AnswerChoice(text: "EPS accretion decreases", isCorrect: true),
                AnswerChoice(text: "EPS unaffected", isCorrect: false),
                AnswerChoice(text: "IRR doubles", isCorrect: false)
            ],
            explanation: "Interest rates doubling → interest expense doubles → Net Income falls significantly → EPS accretion reduced or becomes dilution. Debt financing becomes less attractive when rates rise, reducing or eliminating accretion benefits."
        ),
        Question(
            prompt: "A PE firm buying a strategic company is most likely motivated by:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Short-term arbitrage", isCorrect: false),
                AnswerChoice(text: "Long-term synergy realization", isCorrect: false),
                AnswerChoice(text: "Leveraged returns", isCorrect: true),
                AnswerChoice(text: "Defensive acquisition", isCorrect: false)
            ],
            explanation: "PE firm buying any company (strategic or not) is primarily motivated by financial returns through leverage, operational improvements, and exit within 3-7 years. Even if target is a \"strategic\" company, PE motivation is still leveraged returns, not strategic synergies."
        ),
        Question(
            prompt: "Which of the following best explains why EPS accretion does not equal value creation?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "EPS ignores cost of capital and risk", isCorrect: true),
                AnswerChoice(text: "EPS reflects only synergies", isCorrect: false),
                AnswerChoice(text: "EPS = NPV of synergies", isCorrect: false),
                AnswerChoice(text: "EPS accounts for terminal growth", isCorrect: false)
            ],
            explanation: "EPS accretion is pure accounting—doesn't consider: (1) cost of capital (could overpay), (2) risk (integration may fail), (3) opportunity cost (could deploy capital better elsewhere), (4) timing of cash flows. Value creation requires returns > cost of capital."
        ),
        Question(
            prompt: "Ultimately, M&A success depends on:",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Purchase multiple", isCorrect: false),
                AnswerChoice(text: "Financing mix", isCorrect: false),
                AnswerChoice(text: "Synergy realization and execution", isCorrect: true),
                AnswerChoice(text: "Tax rates", isCorrect: false)
            ],
            explanation: "M&A success = achieving projected synergies and successfully integrating. Execution is everything: realize cost savings, capture revenue synergies, retain key employees, integrate systems/cultures. Finance and structure matter, but execution determines success or failure."
        )
    ]

    static let modules: [Module] = [
        Module(
            title: "M&A Fundamentals",
            subtitle: "Complete M&A mastery - 4 sections",
            emoji: "🤝",
            lessons: [
                Lesson(title: "Section 1: M&A Fundamentals", questions: maSection1),
                Lesson(title: "Section 2: Deal Structures & Mechanics", questions: maSection2),
                Lesson(title: "Section 3: Accretion/Dilution & Synergies", questions: maSection3),
                Lesson(title: "Section 4: Expert-Level M&A Integration", questions: maSection4)
            ]
        ),
        Module(
            title: "LBO Fundamentals",
            subtitle: "Complete LBO mastery - 4 sections",
            emoji: "🏗️",
            lessons: [
                Lesson(title: "Section 1: LBO Fundamentals", questions: lboSection1),
                Lesson(title: "Section 2: Model Setup & Mechanics", questions: lboSection2),
                Lesson(title: "Section 3: Debt, Cash Flows & Returns", questions: lboSection3),
                Lesson(title: "Section 4: Expert-Level PE Reasoning", questions: lboSection4)
            ]
        ),
        Module(
            title: "Valuation Techniques",
            subtitle: "Level 1-4 valuation mastery",
            emoji: "📈",
            lessons: [
                Lesson(title: "Level 1", questions: valuationLevel1),
                Lesson(title: "Level 2", questions: valuationLevel2),
                Lesson(title: "Level 3", questions: valuationLevel3),
                Lesson(title: "Level 4", questions: valuationLevel4)
            ]
        ),
        Module(
            title: "DCF Fundamentals",
            subtitle: "Complete DCF mastery - 4 sections",
            emoji: "💸",
            lessons: [
                Lesson(title: "Section 1: Basics & Concepts", questions: dcfSection1),
                Lesson(title: "Section 2: Building the DCF", questions: dcfSection2),
                Lesson(title: "Section 3: Terminal Value & Sensitivity", questions: dcfSection3),
                Lesson(title: "Section 4: Expert-Level IB Integration", questions: dcfSection4)
            ]
        ),
        Module(
            title: "3 Statements",
            subtitle: "IS, BS, and CF linkage",
            emoji: "📊",
            lessons: [
                Lesson(title: "Linkages", questions: threeStatements)
            ]
        )
    ]
}


