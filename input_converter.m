% input_converter.m

function converted_output = input_converter(stimuli, mode)
    if strcmp(mode, 'eyewise_to_holistic')
        %stimulus should have 8 rows, T columns
        %rows: LE{RM, UM, LM, DM}, RE{RM, UM, LM, DM}
        converted_output = ...
        return converted_output
    elseif strcmp(mode, 'holistic_to_eyewise')
        ...
        converted_output = ...
        return converted_output
    else
        display('Mode must be "eyewise_to_holistic" or "holistic_to_eyewise".')
        return
    end
end