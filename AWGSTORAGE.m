%this class is a map/dictionary implementation which supports multi level
%access like storage.member(3).bla
classdef AWGSTORAGE < handle
    properties
        mData = AWGPULSEGROUP.empty();
    end
    
    methods
        function i = index(self,identifier)
            i = find( strcmp({self.mData.name},identifier) );
            if size(i,2) > 1
                warning('contains %i elements with the key %s.',size(i,2),identifier);
            end
        end
        
        function val = subsref(self,S)
            if strcmp(S(1).type,'()')
                if ischar(S(1).subs{1})
                    if size(S(1).subs,2) ~= 1
                        error('only one key access impleneted');
                    end
                    
                    index = self.index(S(1).subs{1});
                    if isempty(index)
                        error('Key %s not found',S(1).subs{1});
                    end
                    
                    if size(S,2) ~= 1
                        val = subsref( self.mData(index),S(2:end));
                    else
                        val = self.mData(index);
                    end
                else
                    val = subsref(self.mData,S);
                end
            else
                try
                    val = builtin('subsref',self,S);
                catch
                    builtin('subsref',self,S);
                end
            end
        end
        
        function self = subsasgn(self,S,val)
            if strcmp(S(1).type,'()')
                    if ischar(S(1).subs{1})
                        
                        if size(S(1).subs,2) ~= 1
                            error('AWGSTORAGE only supports the access via key of a single element at once for now.');
                        end
                        
                        index = self.index(S(1).subs{1});
                        if isempty(index)
                            if size(S,2) ~= 1
                                error('Can not access members of element %s since it does not exist',self.index(S(1).subs{1}));
                            else
                                error('Key %s not found. No implicit object creation for simplicity/debugging. Use AWGSTORAGE@add to add an object',S(1).subs{1});
                            end
                        else
                            self.mData(index) = subsasgn(self.mData(index),S(2:end),val);
                        end

                        
                    else
                        self.mData = subsasgn( self.mData, S,val);
                    end
            else
                self = builtin('subsasgn',self,S,val);
            end
        end
        
        function remove(self,id)
            if ischar(id)
                index = self.index(id);
                self.mData(index) = [];
            else
                self.mData(id) = [];
            end
        end
        
        function add(self,object)
            self.insert(object, size(self.mData,2)+1)
        end
        
        function insert(self,object,position)
            if ~(isfield(object,'name') || isprop(object,'name') )
                error('May only add objects with the field "name"');
            elseif ~ischar(object.name)
                error('The name field must be a string');
            end
            
            if ~isempty( self.mData )
                if ~isempty( self.index(object.name) )
                    error('Object with key %s already exists.',object.name);
                end
            end
            
            self.mData = [self.mData(1:position-1) object self.mData(position:end)];
        end
        
        function s = length(self)
            try
                s = length(self.mData(1:end));
            catch
                s = 1;
            end
        end
            
        function swap(self,i,j)
            temp = self.mData(i);
            self.mData(i) = self.mData(j);
            self.mData(j) = temp;
        end
        
        function move(self,key,newPosition)
            oldPosition = self.index(key);
            if newPosition < oldPosition
                self.mData = [self.mData(1:newPosition-1) self.mData(oldPosition) self.mData((newPosition+1):oldPosition-1) self.mData((oldPosition+1):end)];
            elseif newPosition > oldPosition
                self.mData = [self.mData(1:oldPosition-1) self.mData((oldPosition+1):newPosition-1) self.mData(oldPosition) self.mData((newPosition+1):end)];
            end
        end
        
        function empty = isempty(self)
            empty = isempty(self.mData);
        end
        
        function iskey = isKey(self,key)
            if isempty(self)
                iskey = false;
            else
                iskey = self.index(key)>0;
            end
        end
    end
end