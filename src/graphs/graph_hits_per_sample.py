import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import re

INPUT_PATH="../../results/deacon_on_public_datasets/"
OUTPUT_PATH="../../figures/"
# accession | sample_name | percentage_hits
df = pd.read_csv(INPUT_PATH + "hits_per_sample_2.csv")
# accession | microbiome_type
meta = pd.read_csv(INPUT_PATH + "Hits_by_microbiome.csv")[['Type of Microbiome', 'Accession', 'Host Filtration', 'Study']]
meta = meta.rename(columns={
    "Type of Microbiome": "microbiome", 
    "Accession": "accession", 
    "Host Filtration": "host_filter",
    "Study": "study"
    })

merged = df.merge(meta, on="accession", how="left")
merged["filtered_status"] = merged["host_filter"].apply(
    lambda x: "Unfiltered" if str(x).lower() == "unfiltered" else "Filtered"
)

# -- Hits per Sample --
plt.figure(figsize=(10, 6))

# Boxplot
sns.boxplot(
    data=merged,
    x="microbiome",
    y="percentage_hits",
    color="lightgray",
    showfliers=False
)

# Scatter plot
sns.stripplot(
    data=merged,
    x="microbiome",
    y="percentage_hits",
    palette="Dark2",
    hue="microbiome",
    dodge=False,
    jitter=True,
    alpha=0.6,
    size=6
)

plt.xlabel("Microbiome Type")
plt.ylabel("% Mapped Reads")
plt.title("% Reads Mapped to Host by Microbiome Type")

plt.legend([], [], frameon=False) # Remove legend

plt.tight_layout()
plt.savefig(
    OUTPUT_PATH + "hits_per_sample_fig.png",
    dpi=600,
    bbox_inches='tight'
)
# plt.show()

# -- Hits per Sample, but removing unfiltered data --
# Remove studies with medians > 50%
study_medians = (
    merged.groupby("study")["percentage_hits"]
    .median()
)
bad_studies = study_medians[study_medians > 0.5].index
filtered = merged[~merged["study"].isin(bad_studies)]

plt.figure(figsize=(10, 6))
sns.boxplot(
    data=filtered,
    x="microbiome",
    y="percentage_hits",
    color="lightgray",
    showfliers=False
)
sns.stripplot(
    data=filtered,
    x="microbiome",
    y="percentage_hits",
    palette="Dark2",
    hue="microbiome",
    dodge=False,
    jitter=True,
    alpha=0.6,
    size=6
)

plt.xlabel("Microbiome Type")
plt.ylabel("% Mapped Reads")
plt.title("% Reads Mapped to Host by Microbiome Type")

plt.legend([], [], frameon=False) # Remove legend

plt.tight_layout()
plt.savefig(
    OUTPUT_PATH + "hits_per_sample_strict_fig.png",
    dpi=600,
    bbox_inches='tight'
)
# plt.show()


# -- Hits per Study --

# Abbreviate the study names
def abbreviate_study(study):
    year = re.search(r'(\d{4})$', study)
    year = year.group(1) if year else ""
    name = re.sub(r'\d{4}$', '', study)
    words = re.findall(r'[A-Z][a-z]*', name)
    initials = ''.join(word[0] for word in words)
    return f"{initials}{year}"
study_map = {
    study: abbreviate_study(study)
    for study in merged["study"].unique()
}
merged["study_short"] = merged["study"].map(study_map)

# Sort by median
study_order = (
    merged.groupby("study_short")["percentage_hits"]
    .median()
    .sort_values()
    .index
)

plt.figure(figsize=(15,6))
sns.boxplot(
    data=merged,
    x="study_short",
    y="percentage_hits",
    order=study_order,
    color="lightgray",
    dodge=False,
    showfliers=False
)
sns.stripplot(
    data=merged,
    x="study_short",
    y="percentage_hits",
    order=study_order,
    hue="host_filter",
    dodge=False,
    jitter=True,
    alpha=0.8,
    size=6
)

# plt.xticks(rotation=45)
plt.ylabel("% Mapped Reads")
plt.xlabel("Study")
plt.title("% Reads Mapped to Host by Study")
plt.legend(title="Reported Host Depletion Method", loc='upper left')

plt.tight_layout()
plt.savefig(
    OUTPUT_PATH +   "hits_per_study_fig.png",
    dpi=600,
    bbox_inches='tight'
)
#plt.show()