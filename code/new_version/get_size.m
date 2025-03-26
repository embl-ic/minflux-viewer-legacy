function size_bytes = get_size (app, this) 
   props = properties(this); 
   size_bytes = 0; 
   
   for ii=1:length(props) 
      currentProperty = getfield(this, char(props(ii))); 
      s = whos('currentProperty'); 
      size_bytes = size_bytes + s.bytes; 
   end
  
   %fprintf(1, '%d bytes\n', size_bytes); 
end