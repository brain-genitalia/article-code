function [v d] = sort_eig(mat)

[v d] = eig(mat);
[v d] = EvSort(v,d);
for ii=1:size(v,2)
    vec = v(:,ii);
    v(:,ii) = vec/norm(vec);
end


function [v d] = EvSort(v, d)

di = diag(d);
[srt_d srt_o] = sort(abs(di));
srt_d = srt_d(end:-1:1);
srt_o = srt_o(end:-1:1);

v = v(:,srt_o);
d = diag(srt_d);
