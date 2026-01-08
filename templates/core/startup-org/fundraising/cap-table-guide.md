# Cap Table Guide

<!-- LLM: Help founders understand equity basics. This is often confusing for first-time founders. Explain clearly without jargon. Emphasize importance of getting this right early - mistakes are expensive to fix later. Encourage getting a lawyer for actual cap table management. -->

**Status:** Living | **Update Frequency:** After each funding round or equity event
**Primary Roles:** Founder/CEO, CFO (if you have one)
**Related Documents:** `/fundraising/fundraising-tracker.md`

## Purpose

Your cap table (capitalization table) tracks who owns what percentage of your company. Getting this right from day one prevents headaches later. This guide covers:
- Equity basics for founders
- How to split founder equity
- Vesting schedules
- Employee equity (options pool)
- How fundraising affects your cap table
- Common mistakes to avoid

**Critical:** This guide is educational. Use a lawyer and cap table management software (Carta, Pulley, AngelList) for your actual cap table.

---

## Equity Basics

### What is Equity?
Ownership in the company, measured in shares. If you have 1,000,000 shares issued and you own 500,000, you own 50% of the company.

### Key Terms

**Authorized Shares:**
- Maximum shares the company can issue (set in incorporation docs)
- Example: 10,000,000 shares authorized

**Issued/Outstanding Shares:**
- Shares actually issued to founders, employees, investors
- Example: 8,000,000 shares issued (2M still available)

**Fully Diluted:**
- All shares that would exist if all options, warrants, convertibles were exercised
- Most important number for calculating ownership %

**Ownership %:**
- Your shares ÷ Fully diluted shares
- Example: 500,000 shares ÷ 10,000,000 fully diluted = 5% ownership

### Pre-Money vs Post-Money Valuation

**Pre-Money Valuation:**
- Company value before new money comes in
- Example: $8M pre-money valuation

**Investment Amount:**
- Money investor is putting in
- Example: $2M investment

**Post-Money Valuation:**
- Pre-money + Investment
- Example: $8M + $2M = $10M post-money

**Investor Ownership:**
- Investment ÷ Post-money valuation
- Example: $2M ÷ $10M = 20% ownership

---

## Founder Equity Split

### At Formation (Day 1)

**Typical Founder Splits:**
- 2 Co-founders: 50/50 or 60/40 (if one is clear CEO)
- 3 Co-founders: 33/33/33 or 40/30/30 (CEO gets more)
- Solo Founder: 100% (rare for VC-backed startups)

**Questions to Consider:**
1. Who had the original idea? (Matters less than you think)
2. Who's full-time vs part-time?
3. Who's CEO vs other roles?
4. Who's taking on most risk?
5. What skills/networks does each bring?

**Common Mistake:** 50/50 split when contributions are unequal
- Better: 60/40 or 55/45 with clear rationale
- Prevents resentment later

**Framework: Calculate by Contribution:**
- Idea: 5-10% weight
- Execution/Time: 40-50% weight
- Domain Expertise: 20-30% weight
- Capital/Network: 10-20% weight

### Founder Vesting

**What is Vesting?**
You earn your equity over time (typically 4 years). If you leave early, you forfeit unvested shares.

**Standard Vesting Schedule:**
- **4-year vesting** with **1-year cliff**
- Year 1: 0% vested (cliff)
- After year 1: 25% vested (cliff occurs)
- Months 13-48: Remaining 75% vests monthly (2.08% per month)

**Example:**
- You're granted 1,000,000 shares
- Month 0-11: 0 shares vested (if you leave, you get nothing)
- Month 12: 250,000 shares vest (cliff)
- Month 13-48: 20,833 shares vest each month
- Month 48: Fully vested (1,000,000 shares)

**Why Vesting Matters:**
- Protects company if founder leaves early
- Standard for investors (they'll require it)
- Fair to founders who stay

**Founder Vesting Negotiation:**
- Credit for time already worked (1 year of vesting)
- Acceleration on acquisition (single or double-trigger)
- Extended vesting for key founders (5-6 years)

---

## Employee Equity (Options Pool)

### Creating an Options Pool

**When:** Before your first fundraise, create an options pool for employees

**Size:** Typically 10-20% of fully diluted shares
- Pre-seed: 10-15% (you won't hire much)
- Seed: 15-20% (hiring your first 5-10 employees)

**How It Works:**
Options pool dilutes founders and existing shareholders, NOT new investors.

**Example:**
- Pre-fundraise: Founders own 100% (8M shares)
- Create 15% options pool: Issue 1.4M more shares
- New total: 9.4M shares
- Founders now own: 8M ÷ 9.4M = 85%
- Options pool: 1.4M ÷ 9.4M = 15%

### Employee Stock Options (ISOs)

**What are Options?**
The right to buy shares at a fixed price (strike price) in the future.

**Types:**
- **ISOs (Incentive Stock Options):** For US employees, tax-advantaged
- **NSOs (Non-Qualified Stock Options):** For contractors, advisors, non-US employees

**How They Work:**
- Employee is granted options with a strike price (usually $0.01/share early on)
- Options vest over 4 years (same as founder vesting)
- Employee can exercise (buy) vested options
- If company sells/IPOs, employee profits: (sale price - strike price) × shares

**Example:**
- Employee granted 100,000 options at $0.10/share strike price
- After 4 years, all options vested
- Employee exercises (pays $10,000 for 100,000 shares)
- Company acquired at $5/share
- Employee sells for $500,000
- Profit: $490,000

### Equity Guidelines by Role

**Typical Equity Grants (at Seed Stage):**

| Role | Equity Range | Notes |
|------|--------------|-------|
| Co-founder (early) | 5-20% | Depends on timing, role, vesting |
| First Engineer | 0.5-1.5% | Higher if truly #1 employee |
| VP Engineering | 0.5-1.5% | Depends on stage when hired |
| Engineer #2-5 | 0.1-0.5% | Decreases as company grows |
| Senior Engineer | 0.05-0.25% | After first 10 hires |
| First PM/Designer | 0.25-1% | Early product hire |
| Advisors | 0.1-0.5% | Vests over 2 years typically |

**Note:** These decrease as company grows and valuation increases.

---

## How Fundraising Affects Your Cap Table

### Pre-Seed / Seed Example

**Starting Point:**
- 2 Founders: 50/50 split (4M shares each)
- Options Pool: 15% (1.4M shares)
- Total: 9.4M shares fully diluted

**Raise $2M at $8M pre-money ($10M post-money):**

**Calculation:**
- Investor owns: $2M ÷ $10M = 20%
- Need to issue shares so investor owns 20%
- Current shares: 9.4M = 80% (since investor will own 20%)
- Total shares after: 9.4M ÷ 0.80 = 11.75M
- New shares issued to investor: 11.75M - 9.4M = 2.35M shares

**Cap Table After Seed:**
| Shareholder | Shares | % Ownership |
|-------------|--------|-------------|
| Founder 1 | 4,000,000 | 34.0% |
| Founder 2 | 4,000,000 | 34.0% |
| Options Pool | 1,400,000 | 11.9% |
| Seed Investor | 2,350,000 | 20.0% |
| **Total** | **11,750,000** | **100%** |

**Founder Dilution:**
- Before: 50% each
- After: 34% each
- Dilution: 32%

### Series A Example (12 months later)

**Starting Point (Post-Seed):**
- Total shares: 11.75M
- Some options granted (200K used from pool)

**Raise $5M at $20M pre-money ($25M post-money):**
- Investor owns: $5M ÷ $25M = 20%
- New shares issued: 2.94M

**Cap Table After Series A:**
| Shareholder | Shares | % Ownership |
|-------------|--------|-------------|
| Founder 1 | 4,000,000 | 27.2% |
| Founder 2 | 4,000,000 | 27.2% |
| Options Pool | 1,200,000 | 8.2% (200K granted) |
| Seed Investor | 2,350,000 | 16.0% |
| Series A Investor | 2,940,000 | 20.0% |
| Employees (options) | 200,000 | 1.4% |
| **Total** | **14,690,000** | **100%** |

**Founder Ownership Over Time:**
- At formation: 50% each
- After Seed: 34% each
- After Series A: 27.2% each

**This is Normal.** Your slice of the pie shrinks, but the pie grows. 27% of a $25M company > 50% of $0.

---

## SAFEs and Convertible Notes

### SAFE (Simple Agreement for Future Equity)

**What is it?**
Investment that converts to equity later (usually at next priced round).

**Key Terms:**
- **Valuation Cap:** Maximum valuation at which SAFE converts
  - Example: $10M cap means investor gets better price if next round is >$10M valuation
- **Discount:** % discount on next round price
  - Example: 20% discount means they pay 80% of Series A price

**Example:**
- Raise $500K on SAFE with $10M cap, 20% discount
- 12 months later, raise Series A at $20M pre-money
- SAFE converts at $10M cap (better than $20M)
- SAFE investor gets: $500K ÷ $10M × (post-money Series A shares) = 5% ownership (before Series A dilution)

**Pros:**
- Fast to close (no valuation negotiation)
- Cheap (less legal fees than priced round)
- Founder-friendly (no board seats, fewer terms)

**Cons:**
- Cap table is messy until SAFE converts
- Can create unexpected dilution if cap is low

### Convertible Note

Similar to SAFE but it's debt that converts to equity. Less common now (SAFEs are standard).

---

## Common Cap Table Mistakes

### 1. No Founder Vesting
**Mistake:** Founders get shares with no vesting
**Problem:** If co-founder leaves after 6 months, they keep 50% of company
**Solution:** 4-year vesting with 1-year cliff for ALL founders

### 2. Too Large Options Pool Too Early
**Mistake:** Creating 25% options pool at formation
**Problem:** Dilutes founders unnecessarily when you won't hire for months
**Solution:** 10-15% pool before Seed, expand later if needed

### 3. Giving Away Too Much Equity Early
**Mistake:** Giving advisors 2-3% equity, early employees 5%
**Problem:** Run out of equity before you've built a team
**Solution:** Be stingy early. 0.1-0.5% for advisors, 0.5-1.5% for first employees

### 4. Not Using Cap Table Software
**Mistake:** Managing cap table in Excel
**Problem:** Error-prone, hard to model scenarios, missing 409A valuations
**Solution:** Use Carta, Pulley, or AngelList from day one ($0-$300/month)

### 5. Ignoring 409A Valuations
**Mistake:** Not getting 409A valuations for option grants
**Problem:** IRS penalties, employee tax issues
**Solution:** Get 409A every 12 months or after funding round ($1-3K)

### 6. Equal Splits When Contributions Aren't Equal
**Mistake:** 50/50 split when one founder is CEO, full-time, and other is part-time advisor
**Problem:** Resentment, unfair when part-time founder leaves
**Solution:** 60/40 or 70/30 split reflecting actual contribution

### 7. Verbal Agreements on Equity
**Mistake:** "We'll figure out equity later" or handshake deals
**Problem:** Leads to disputes, lawsuits, broken companies
**Solution:** Get everything in writing from day one, signed by all parties

---

## Cap Table Best Practices

### 1. Use Professional Software
- **Carta** (most popular, $0-300/month)
- **Pulley** (newer, simpler, similar price)
- **AngelList** (free if you fundraise on AngelList)

**Don't:** Manage in Excel/Google Sheets (error-prone)

### 2. Get a Lawyer
- Incorporate properly (Delaware C-Corp for VC-backed startups)
- 83(b) election for founder stock (critical tax filing)
- Option grant paperwork
- Fundraise documents

**Cost:** $2-5K for incorporation, $5-15K per fundraise

### 3. Keep It Current
- Update after every option grant
- Update after every funding round
- Update when employees exercise options
- Review quarterly for accuracy

### 4. Model Dilution
Before each fundraise, model scenarios:
- How much will founders be diluted?
- Do we need to increase options pool?
- What % will we own after Series A, B, C?

**Tool:** Use cap table software's scenario planning

### 5. Be Transparent (To A Point)
**Share with:**
- Founders (full transparency)
- Investors (full transparency)
- Employees (their own equity only, not others')

**Don't:**
- Show entire cap table to all employees (causes issues)
- Share valuation publicly until Series B+

---

## Founder Ownership Over Time

### Typical Dilution Path

| Stage | Founder Ownership | Notes |
|-------|------------------|-------|
| Formation | 50% each (2 co-founders) | 100% total to founders |
| After Options Pool (15%) | 42.5% each | Diluted by options pool |
| After Seed ($2M at $8M pre) | 34% each | ~20% dilution |
| After Series A ($5M at $20M pre) | 27% each | ~20% dilution |
| After Series B ($15M at $50M pre) | 21% each | ~20-25% dilution |
| After Series C ($30M at $150M pre) | 16% each | ~20-25% dilution |
| At IPO/Exit | 10-15% each | After multiple rounds |

**Key Insight:**
- Expect 20-25% dilution per fundraise
- Each founder typically owns 10-20% at exit (for successful VC-backed startup)
- 15% of $500M company = $75M (founders usually do fine)

---

## Resources and Tools

### Cap Table Software
- [Carta](https://carta.com) - Industry standard
- [Pulley](https://pulley.com) - Newer, simpler
- [AngelList](https://angellist.com) - Free with their fundraising platform

### Legal
- [Clerky](https://clerky.com) - DIY incorporation and fundraising docs ($1-2K)
- **Law Firm** - For complex situations ($5-15K per fundraise)

### Learning Resources
- [Carta Equity 101](https://carta.com/learn/equity/) - Free course
- [Holloway Guide to Equity Compensation](https://www.holloway.com/g/equity-compensation)
- [Y Combinator's SAFE resources](https://www.ycombinator.com/documents)

---

## Sample Cap Table Template

### Simple Cap Table (Formation)

| Shareholder | Shares | % Fully Diluted | Vesting | Notes |
|-------------|--------|-----------------|---------|-------|
| Founder 1 (CEO) | 4,500,000 | 45% | 4yr, 1yr cliff | Founder vesting starts [date] |
| Founder 2 (CTO) | 4,500,000 | 45% | 4yr, 1yr cliff | Founder vesting starts [date] |
| Options Pool | 1,000,000 | 10% | - | Reserved for employees |
| **Total** | **10,000,000** | **100%** | - | - |

### After Seed Round

| Shareholder | Shares | % Fully Diluted | Investment | Valuation |
|-------------|--------|-----------------|------------|-----------|
| Founder 1 (CEO) | 4,500,000 | 36% | - | - |
| Founder 2 (CTO) | 4,500,000 | 36% | - | - |
| Options Pool | 1,000,000 | 8% | - | - |
| Seed Investor A | 1,500,000 | 12% | $1.2M | $10M post-money |
| Seed Investor B | 1,000,000 | 8% | $800K | $10M post-money |
| **Total** | **12,500,000** | **100%** | **$2M** | **$10M post-money** |

---

**Last Updated:** [Date]
**Next Review:** [After each funding round or major equity event]
**Document Owner:** Founder/CEO, CFO

<!-- LLM: When helping founders with cap table questions, emphasize: 1) Get a lawyer and use proper software, 2) Founder vesting is non-negotiable, 3) Dilution is normal and expected, 4) Percentage matters less than absolute value (10% of $500M > 50% of $0), 5) Don't give away too much equity too early. Be clear that you're providing education, not legal advice. -->
