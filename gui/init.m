function init
%  PURPOSE:  set paths
%           
%  USAGE:   init
%
%  INPUTS:  
%
%  OUTPUTS: 
%
%  COMMENTS:

% Copyright  (c) Pawel Kowal (2007-2008), Institute for Structural Research
% All rights reserved
% This file is a part of Forma Toolbox v. 2.3 
% The Forma Toolkbox is available free for academic use only     
% contact pawel.kowal@ibs.org.pl

P               = which( 'init' );
P(end-5:end)    = [];

paths          = ...
{
    'gui_main','gui_modal'
};
for i=1:1:length(paths)
    add_path([P paths{i}]);
end

function add_path(path)
addpath(path);
cd(path);
init;
cd('../');