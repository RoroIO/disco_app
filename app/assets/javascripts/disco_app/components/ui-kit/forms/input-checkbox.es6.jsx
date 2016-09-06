const InputCheckbox = ({ label, name, value, checked, inline, isLast, onChange }) => {

  const id = `${name}[${value}]`;

  const wrapperClassName = classNames({
    'next-input-wrapper': true,
    'inline': inline,
    'sr': !isLast
  });

  const labelClassName = classNames({
    'next-label': true,
    'next-label--switch': true,
    'inline': inline,
    'fw-normal': inline
  });

  const handleChange = (e) => {
    onChange && onChange(e.target.value);
  };

  return(
    <div className={wrapperClassName}>
      <label htmlFor={id} className={labelClassName}>{label}</label>
      <input id={id} className="next-checkbox" type="checkbox" value={value} name={name} checked={checked} onChange={handleChange} />
      <span className="next-checkbox--styled" />
    </div>
  )

};
