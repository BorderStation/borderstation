///This datum is a simple holder for the micro_organisms in a sample.
/datum/biological_sample
	///List of all micro_organisms in the sample
	var/list/micro_organisms = list()
	///Prevents someone from stacking too many layers onto a swabber
	var/sample_layers = 1
	///Picked from a specific group of colors, limited to a specific group.
	var/sample_color = SAMPLE_YELLOW

///Gets info from each of it's micro_organisms.
/datum/biological_sample/proc/GetAllDetails(show_needs)
	var/list/info = list()
	for(var/i in micro_organisms)
		var/datum/micro_organism/MO = i
		info += MO.GetDetails(show_needs)
	return info.Join()

///Generate a sample from a specific weighted list, and a specific amount of cell line with a chance for a virus
/datum/biological_sample/proc/GenerateSample(cell_line_define, virus_define, cell_line_amount, virus_chance)
	sample_color = pick(GLOB.xeno_sample_colors)

	var/list/temp_weight_list = GLOB.cell_line_tables[cell_line_define].Copy() //Temp list to prevent double picking
	for(var/i in 1 to cell_line_amount)
		var/datum/micro_organism/chosen_type = pickweight(temp_weight_list)
		temp_weight_list -= chosen_type
		micro_organisms += new chosen_type
	if(virus_chance)
		if(!GLOB.cell_virus_tables[virus_define])
			return
		var/datum/micro_organism/chosen_type = pickweight(GLOB.cell_virus_tables[virus_define])
		micro_organisms += new chosen_type

///Takes another sample and merges it into use. This can cause one very big sample but we limit it to 3 layers.
/datum/biological_sample/proc/Merge(var/datum/biological_sample/other_sample)
	if(sample_layers >= 3)//No more than 3 layers, at that point you're entering danger zone.
		return FALSE
	micro_organisms += other_sample.micro_organisms
	qdel(other_sample)
	return TRUE

///Call HandleGrowth on all our microorganisms.
/datum/biological_sample/proc/HandleGrowth(var/obj/machinery/plumbing/growing_vat/vat)
	for(var/datum/micro_organism/cell_line/organism in micro_organisms) //Types because we don't grow viruses.
		return organism.HandleGrowth(vat)
