function size_bytes = get_size (variable) 
   props = properties(variable); 
   size_bytes = 0; 
   
   for ii=1:length(props) 
      currentProperty = getfield(variable, char(props(ii))); 
      s = whos('currentProperty'); 
      size_bytes = size_bytes + s.bytes; 
   end
  
   %fprintf(1, '%d bytes\n', size_bytes); 
end