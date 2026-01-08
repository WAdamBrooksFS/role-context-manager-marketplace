# Data Scientist - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build predictive models, statistical analysis, experiment design
**Organizational Level:** Project
**Key Documents Created:** Model documentation, experiment reports, analysis notebooks
**Key Documents Consumed:** PRDs, data requirements, data governance policy

## Deterministic Behaviors

### When Building ML Models

**AI MUST:**
- Follow engineering standards for code quality
- Include model evaluation metrics (accuracy, precision, recall, F1)
- Document feature engineering process
- Include data validation and quality checks
- Ensure reproducibility (version data, code, models)
- Address bias and fairness considerations
- Never expose PII in logs or outputs

**Validation Checklist:**
- [ ] Model performance metrics documented
- [ ] Training/validation/test split appropriate
- [ ] Feature engineering documented
- [ ] Model versioning implemented
- [ ] Bias and fairness assessed
- [ ] PII handling compliant with `/data-governance.md`
- [ ] Code tested and reproducible
- [ ] Model monitoring planned

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest feature engineering improvements
- Recommend model architecture alternatives
- Flag potential bias or fairness issues
- Identify data quality problems
- Propose experiment designs
- Highlight when more data is needed

### Data Science Support

**AI CAN help with:**
- Feature engineering ideas
- Model selection guidance
- Code implementation
- Statistical analysis
- Experiment design
- Documentation generation
- Data visualization
- Model explanation (SHAP, LIME)

## Common Workflows

### Workflow 1: Build Predictive Model

```
1. Data Scientist: "Build model to predict customer churn"
2. AI: Design approach:
   - Features: usage patterns, support tickets, payment history
   - Model: Random Forest or XGBoost
   - Evaluation: Precision/recall (imbalanced classes)
3. AI: Generate code:
   - Data loading and cleaning
   - Feature engineering
   - Model training
   - Evaluation
4. AI: Document results and next steps
5. Data Scientist: Refines and iterates
```

### Workflow 2: Experiment Design and Analysis

```
1. Data Scientist: "Design A/B test for new recommendation algorithm"
2. AI: Design experiment:
   - Hypothesis: New algo improves CTR by 10%
   - Sample size calculation
   - Success metrics (CTR, revenue, engagement)
   - Duration (2 weeks for statistical power)
3. AI: Create analysis plan
4. AI: Generate analysis code
5. Data Scientist: Reviews and runs experiment
```

## Common Pitfalls

### Pitfall 1: No Train/Test Split
**Bad:** Evaluating model on training data
**Good:** Proper train/validation/test split
**AI should flag:** "Model evaluated on training data. Split into train/val/test sets."

### Pitfall 2: Data Leakage
**Bad:** Future information in features
**Good:** Only past information used
**AI should flag:** "Feature uses future data. This causes data leakage."

### Pitfall 3: Ignoring Class Imbalance
**Bad:** Using accuracy for imbalanced classes
**Good:** Use precision, recall, F1, or ROC-AUC
**AI should flag:** "Dataset has 1% positive class. Use precision/recall instead of accuracy."

## Success Metrics for AI Collaboration

- Models meet performance targets
- Experiments designed with statistical rigor
- Code reproducible and documented
- Bias and fairness assessed
- Models deployed successfully to production

---

**Last Updated:** 2024-03-20
**Guide Owner:** Data Science Team
