


# load index into array

# load pages into array, indexed with actual page numbers pb@n attributed.



sub applyEntry
{
	my $entry = shift;
	my $pageNumber = shift;

	my $pageContent = $page[$pageNumber];

	# search for entry

	if (contains($pageContent, $entry))
	{
		my $entryId = createEntryId($entry);

		$page[$pageNumber] = insertEntry($pageContent, $entry);
	}
	else
	{
		print STDERR "ERROR: Entry '$entry' not found on page $pageNumber\n";
	}
}


sub contains
{
	my $entry = shift;
	my $text = shift;

	


}