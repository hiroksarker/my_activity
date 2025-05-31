showDialog(
  context: context,
  builder: (context) => AddLedgerEntryDialog(
    onAdd: (entry) {
      // Call your provider to add the entry
      Provider.of<LedgerProvider>(context, listen: false).addEntry(entry);
    },
    accounts: yourAccountsList,     // List<Account>
    categories: yourCategoriesList, // List<Category>
  ),
);
