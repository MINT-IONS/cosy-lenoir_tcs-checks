function out = verbose(in)
% verbose  Set/Get verbosity level of tcs2 functions.
%    tcs2.verbose(1)  standard verbosity
%    tcs2.verbose(2)  standard verbosity + prints serial trafic
%
%    v = tcs2.verbose  get current verbosity level.

persistent VERBOSE

if nargin
    VERBOSE = in;
    if in > 0
        fprintf('tcs2 verbosity set to %d.\n', in)
    end
end

if nargout
    if isempty(VERBOSE)
        VERBOSE = 1;
    end
    out = VERBOSE;
end
