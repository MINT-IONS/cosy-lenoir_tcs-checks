function current_tcs(comstr)
% current_tcs  Select current TCS2 device.
%    tcs2.current_tcs('COM#')  where 'COM#' is a COM port that has been open via tcs3.init_serial(),
%    selects the corresponding TCS2 device as the current one; every subsequent operations will then
%    be applied to it.
%
%  
%  Benvenuto JACOB, UCLouvain, Jul 2022.

if nargout
    comobj = TCS2_SERIAL;
end
