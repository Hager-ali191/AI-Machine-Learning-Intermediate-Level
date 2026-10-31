### To:
Amira Al-Fayed, Product Lead, OmniStream Media

### From:
Data Science Analyst, Analytics Team, OmniStream Media

### Subject:
Q3 Budget Proposal: Upgrading Our Content Recommendation Engine

---

### Opening Statement
Hi Amira,

Thank you for making time ahead of the Q3 budget review. I'm writing to propose an upgrade to OmniStream Media's primary content recommendation engine, and to give you a clear, jargon-free picture of how the data science behind it works so you can present it confidently to the executive board. Below you'll find a simple analogy, the seven steps that take us from raw viewing records to a live business decision, and a summary of the tools we'll use.

### Section 1: The Analogy
Think of how Netflix seems to know what you want to watch next. It isn't guessing. It keeps a record of what millions of viewers have watched, how long they stayed, and how they rated each title. That record is historical data, and it is full of patterns: viewers who finished a gripping sci-fi film often enjoy similar stories, while a title abandoned after ten minutes tells us something too. The system compares each viewer with others who have similar tastes and suggests what those viewers loved. At OmniStream Media, our own historical data works the same way. Every watch session and rating becomes a clue, and the upgraded engine turns those clues into a personalised homepage for each subscriber, helping them find something they enjoy faster and stay with us longer.

### Section 2: The Workflow
1. **Problem Definition:** Together with stakeholders, we agree on one measurable goal, such as helping subscribers find something they enjoy faster so they watch more and cancel less.
2. **Data Collection:** We gather the raw viewing records (who watched what, for how long, and how they rated it) from across our platform into a single, reliable pipeline.
3. **Data Cleaning & Preparation:** We remove duplicates, fill gaps, and standardise entries, and we review outliers, such as a film abandoned after only a few minutes, so unusual records do not mislead the system.
4. **Exploratory Data Analysis:** Through exploratory data analysis (EDA), we chart the cleaned data to see which genres hold attention, how ratings relate to watch time, and which viewer habits are worth building on.
5. **Model Selection & Training:** We choose a recommendation method that learns from viewers with similar tastes and train it on past viewing and ratings.
6. **Model Evaluation & Tuning:** We test the engine on viewing records it has never seen and fine-tune it until its suggestions are accurate enough to justify launch.
7. **Deployment & Monitoring:** Once approved, we switch the engine on for subscribers, track its impact on watch time and cancellations, and retrain it on fresh data as tastes change.

### Section 3: The Tools
We will rely on four industry-standard tools, each matched to the stages where it adds the most value; the full breakdown is in the supplementary `tool_stage_mapping.csv` file. SQL is our "librarian": it pulls viewing records from our databases in Stage 2 and tidies them in Stage 3. Python is our "workshop": it combines and cleans data, explores patterns in Stage 4, builds and tests the recommendation model in Stages 5 and 6, and runs it live in Stage 7. Excel supports quick checks and simple comparisons, such as setting baseline targets in Stage 1 and reviewing sample records and results along the way. Tableau turns the findings into clear visual dashboards for you and the stakeholders, from framing the goal in Stage 1 to tracking live performance in Stage 7. In short, our resource allocation maps directly onto the seven-step workflow, so every budget line supports a specific stage and nothing is spent on tools we won't use.

I'd be happy to walk you through any part of this before the board meeting.

Best regards,
Data Science Analyst, Analytics Team, OmniStream Media
