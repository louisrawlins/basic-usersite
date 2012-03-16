# returns bins for hystogram of values
def bins(values,*params)
  params = params.last
  min = params[:min] || values.min
  max = params[:max] || values.max
  bins_count = params[:bins_count] || 5

  bins = [0] * bins_count
  values.each do |score|
    bins[ bins_count * (score - min) / (max - min + 0.000000001) ] += 1 if
      (min..max).cover? score
  end

  { min:  min,
    max:  max,
    bins: bins }
end
